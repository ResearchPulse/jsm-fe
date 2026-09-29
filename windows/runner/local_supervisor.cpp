#include <winsock2.h>
#include <ws2tcpip.h>

#include "local_supervisor.h"

#include <bcrypt.h>
#include <windows.h>

#include <algorithm>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <map>
#include <sstream>
#include <utility>

namespace {

constexpr char kLoopbackAddress[] = "127.0.0.1";
constexpr char kRuntimeTokenHeader[] = "X-JSM-Runtime-Token";

std::string ToUtf8(const std::wstring& value) {
  if (value.empty()) return {};
  const int size = WideCharToMultiByte(CP_UTF8, 0, value.data(),
                                      static_cast<int>(value.size()), nullptr,
                                      0, nullptr, nullptr);
  if (size <= 0) return {};
  std::string result(size, '\0');
  WideCharToMultiByte(CP_UTF8, 0, value.data(),
                      static_cast<int>(value.size()), result.data(), size,
                      nullptr, nullptr);
  return result;
}

std::wstring EnvironmentValue(const wchar_t* name) {
  const DWORD required = GetEnvironmentVariableW(name, nullptr, 0);
  if (required == 0) return {};
  std::wstring value(required, L'\0');
  const DWORD copied = GetEnvironmentVariableW(name, value.data(), required);
  if (copied == 0 || copied >= required) return {};
  value.resize(copied);
  return value;
}

std::wstring CurrentExecutablePath() {
  std::wstring buffer(MAX_PATH, L'\0');
  for (;;) {
    const DWORD copied = GetModuleFileNameW(nullptr, buffer.data(),
                                            static_cast<DWORD>(buffer.size()));
    if (copied == 0) return {};
    if (copied < buffer.size() - 1) {
      buffer.resize(copied);
      return buffer;
    }
    buffer.resize(buffer.size() * 2);
  }
}

bool IsUsablePort(uint16_t port) { return port != 0; }

uint16_t FindAvailablePort() {
  SOCKET socket_handle = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (socket_handle == INVALID_SOCKET) return 0;

  sockaddr_in address{};
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  address.sin_port = htons(0);
  const int bind_result = bind(socket_handle,
                               reinterpret_cast<const sockaddr*>(&address),
                               sizeof(address));
  if (bind_result != 0) {
    closesocket(socket_handle);
    return 0;
  }

  int address_length = sizeof(address);
  const int name_result = getsockname(
      socket_handle, reinterpret_cast<sockaddr*>(&address), &address_length);
  closesocket(socket_handle);
  if (name_result != 0) return 0;
  return ntohs(address.sin_port);
}

std::string HexToken(const std::vector<unsigned char>& bytes) {
  static constexpr char kHex[] = "0123456789abcdef";
  std::string token;
  token.reserve(bytes.size() * 2);
  for (const unsigned char byte : bytes) {
    token.push_back(kHex[(byte >> 4) & 0x0f]);
    token.push_back(kHex[byte & 0x0f]);
  }
  return token;
}

bool CreateRuntimeToken(std::string* token) {
  std::vector<unsigned char> bytes(32);
  if (BCryptGenRandom(nullptr, bytes.data(), static_cast<ULONG>(bytes.size()),
                      BCRYPT_USE_SYSTEM_PREFERRED_RNG) != 0) {
    return false;
  }
  *token = HexToken(bytes);
  return true;
}

std::wstring MakeDataRoot() {
  auto local_app_data = EnvironmentValue(L"LOCALAPPDATA");
  if (local_app_data.empty()) {
    local_app_data = EnvironmentValue(L"USERPROFILE");
    if (!local_app_data.empty()) {
      local_app_data += L"\\AppData\\Local";
    }
  }
  if (local_app_data.empty()) return {};
  return (std::filesystem::path(local_app_data) / L"JSM").wstring();
}

std::wstring BuildEnvironmentBlock(
    const std::map<std::wstring, std::wstring>& overrides) {
  std::map<std::wstring, std::wstring> environment;
  LPWCH raw = GetEnvironmentStringsW();
  if (raw != nullptr) {
    for (LPWCH entry = raw; *entry != L'\0';
         entry += wcslen(entry) + 1) {
      const std::wstring value(entry);
      const size_t separator = value.find(L'=');
      if (separator == std::wstring::npos || separator == 0) continue;
      environment[value.substr(0, separator)] =
          value.substr(separator + 1);
    }
    FreeEnvironmentStringsW(raw);
  }

  for (const auto& [key, value] : overrides) environment[key] = value;

  std::wstring block;
  for (const auto& [key, value] : environment) {
    block.append(key);
    block.push_back(L'=');
    block.append(value);
    block.push_back(L'\0');
  }
  block.push_back(L'\0');
  return block;
}

bool ProcessExited(HANDLE process, DWORD* exit_code) {
  if (process == nullptr) return true;
  if (GetExitCodeProcess(process, exit_code) == FALSE) return true;
  return *exit_code != STILL_ACTIVE;
}

}  // namespace

LocalSupervisor::LocalSupervisor() : LocalSupervisor(Options{}) {}

LocalSupervisor::LocalSupervisor(Options options) : options_(std::move(options)) {}

LocalSupervisor::~LocalSupervisor() { Stop(); }

LocalSupervisor::RuntimeConfig LocalSupervisor::runtime_config() const {
  std::lock_guard<std::mutex> lock(state_mutex_);
  return runtime_config_;
}

std::string LocalSupervisor::LastError() const {
  std::lock_guard<std::mutex> lock(state_mutex_);
  return last_error_;
}

std::vector<std::string> LocalSupervisor::DartEntrypointArguments() const {
  std::lock_guard<std::mutex> lock(state_mutex_);
  return {
      "--jsm-api-base-url=" + runtime_config_.api_base_url,
      "--jsm-api-port=" + std::to_string(runtime_config_.api_port),
      "--jsm-sso-callback-port=" +
          std::to_string(runtime_config_.sso_callback_port),
      "--jsm-profile=" + runtime_config_.profile,
      "--jsm-runtime-token=" + runtime_config_.runtime_token,
  };
}

void LocalSupervisor::SetError(std::string message) {
  {
    std::lock_guard<std::mutex> lock(state_mutex_);
    last_error_ = std::move(message);
  }
  WriteDiagnostic(LastError());
}

void LocalSupervisor::WriteDiagnostic(const std::string& message) const {
  OutputDebugStringA(("JSM supervisor: " + message + "\n").c_str());

  const std::wstring local_app_data = EnvironmentValue(L"LOCALAPPDATA");
  if (local_app_data.empty()) return;
  const auto log_directory =
      std::filesystem::path(local_app_data) / L"JSM" / L"logs";
  std::error_code error;
  std::filesystem::create_directories(log_directory, error);
  if (error) return;
  std::ofstream log(log_directory / L"desktop-supervisor.log",
                    std::ios::out | std::ios::app);
  if (log) log << message << '\n';
}

bool LocalSupervisor::ResolveRuntimePaths() {
  const std::filesystem::path executable_path(CurrentExecutablePath());
  if (executable_path.empty()) {
    SetError("Could not resolve the desktop executable directory.");
    return false;
  }

  const auto runtime_root = options_.runtime_root.empty()
                                ? executable_path.parent_path() / L"runtime"
                                : std::filesystem::path(options_.runtime_root);
  api_path_ = (runtime_root / L"jsm-api" / options_.api_executable).wstring();
  worker_path_ =
      (runtime_root / L"jsm-worker" / options_.worker_executable).wstring();

  std::error_code error;
  if (!std::filesystem::is_regular_file(api_path_, error)) {
    SetError("Bundled API sidecar is missing: " + ToUtf8(api_path_));
    return false;
  }
  if (!std::filesystem::is_regular_file(worker_path_, error)) {
    SetError("Bundled worker sidecar is missing: " + ToUtf8(worker_path_));
    return false;
  }

  data_root_ = MakeDataRoot();
  if (data_root_.empty()) {
    SetError("Could not resolve a user-writable LOCALAPPDATA directory.");
    return false;
  }
  worker_ready_path_ =
      (std::filesystem::path(data_root_) / L"data" / L"worker.ready").wstring();
  stop_file_path_ =
      (std::filesystem::path(data_root_) / L"data" / L"runtime.stop").wstring();
  return true;
}

bool LocalSupervisor::BuildRuntimeConfig() {
  if (!winsock_started_) {
    WSADATA data{};
    if (WSAStartup(MAKEWORD(2, 2), &data) != 0) {
      SetError("Could not initialize Winsock for the local supervisor.");
      return false;
    }
    winsock_started_ = true;
  }

  for (int attempt = 0; attempt < 8; ++attempt) {
    runtime_config_.api_port = FindAvailablePort();
    runtime_config_.sso_callback_port = FindAvailablePort();
    if (IsUsablePort(runtime_config_.api_port) &&
        IsUsablePort(runtime_config_.sso_callback_port) &&
        runtime_config_.api_port != runtime_config_.sso_callback_port) {
      break;
    }
  }
  if (!IsUsablePort(runtime_config_.api_port) ||
      !IsUsablePort(runtime_config_.sso_callback_port) ||
      runtime_config_.api_port == runtime_config_.sso_callback_port) {
    SetError("Could not negotiate separate loopback API and SSO ports.");
    return false;
  }

  if (!CreateRuntimeToken(&runtime_config_.runtime_token)) {
    SetError("Could not create the local runtime token.");
    return false;
  }
  runtime_config_.api_base_url =
      "http://127.0.0.1:" + std::to_string(runtime_config_.api_port) +
      "/api/v1";
  return true;
}

bool LocalSupervisor::StartChild(const std::wstring& executable,
                                 ChildProcess* child) {
  std::map<std::wstring, std::wstring> overrides = {
      {L"RUNTIME_PROFILE", L"desktop"},
      {L"JSM_API_HOST", L"127.0.0.1"},
      {L"JSM_API_PORT", std::to_wstring(runtime_config_.api_port)},
      {L"API_PORT", std::to_wstring(runtime_config_.api_port)},
      {L"JSM_SSO_CALLBACK_PORT",
       std::to_wstring(runtime_config_.sso_callback_port)},
      {L"JSM_RUNTIME_TOKEN", std::wstring(runtime_config_.runtime_token.begin(),
                                           runtime_config_.runtime_token.end())},
      {L"APP_DATA_DIR", data_root_},
      {L"JSM_WORKER_READY_FILE", worker_ready_path_},
      {L"JSM_STOP_FILE", stop_file_path_},
  };
  const std::filesystem::path executable_path(executable);
  const std::wstring working_directory = executable_path.parent_path().wstring();
  std::wstring command_line = L"\"" + executable + L"\"";
  std::wstring environment = BuildEnvironmentBlock(overrides);

  STARTUPINFOW startup_info{};
  startup_info.cb = sizeof(startup_info);
  PROCESS_INFORMATION process_info{};
  const BOOL created = CreateProcessW(
      nullptr, command_line.data(), nullptr, nullptr, FALSE,
      CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP | CREATE_UNICODE_ENVIRONMENT,
      environment.data(), working_directory.c_str(), &startup_info,
      &process_info);
  if (created == FALSE) {
    SetError("Could not start sidecar " + ToUtf8(executable) + " (Win32 " +
             std::to_string(GetLastError()) + ").");
    return false;
  }

  CloseHandle(process_info.hThread);
  child->process = process_info.hProcess;
  child->process_id = process_info.dwProcessId;
  child->executable = executable;
  return true;
}

bool LocalSupervisor::ProbeReady() {
  SOCKET socket_handle = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (socket_handle == INVALID_SOCKET) return false;

  const DWORD timeout_ms = 500;
  setsockopt(socket_handle, SOL_SOCKET, SO_RCVTIMEO,
             reinterpret_cast<const char*>(&timeout_ms), sizeof(timeout_ms));
  setsockopt(socket_handle, SOL_SOCKET, SO_SNDTIMEO,
             reinterpret_cast<const char*>(&timeout_ms), sizeof(timeout_ms));

  sockaddr_in address{};
  address.sin_family = AF_INET;
  inet_pton(AF_INET, kLoopbackAddress, &address.sin_addr);
  address.sin_port = htons(runtime_config_.api_port);
  if (connect(socket_handle, reinterpret_cast<const sockaddr*>(&address),
              sizeof(address)) != 0) {
    closesocket(socket_handle);
    return false;
  }

  const std::string request =
      "GET " + options_.readiness_path +
      " HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n" +
      kRuntimeTokenHeader + ": " + runtime_config_.runtime_token + "\r\n\r\n";
  const int sent = send(socket_handle, request.data(),
                        static_cast<int>(request.size()), 0);
  if (sent != static_cast<int>(request.size())) {
    closesocket(socket_handle);
    return false;
  }

  char buffer[1024];
  std::string response;
  int received = 0;
  while ((received = recv(socket_handle, buffer, sizeof(buffer), 0)) > 0) {
    response.append(buffer, received);
    if (response.size() > 16 * 1024) break;
  }
  closesocket(socket_handle);
  return response.find("HTTP/1.1 200") == 0 ||
         response.find("HTTP/1.0 200") == 0;
}

bool LocalSupervisor::WaitForApiReady() {
  const auto deadline = std::chrono::steady_clock::now() +
                        std::chrono::milliseconds(options_.readiness_timeout_ms);
  while (std::chrono::steady_clock::now() < deadline) {
    DWORD exit_code = STILL_ACTIVE;
    if (ProcessExited(api_.process, &exit_code)) {
      SetError("API sidecar exited before /ready (code " +
               std::to_string(exit_code) + ").");
      return false;
    }
    if (ProbeReady()) return true;
    Sleep(100);
  }
  SetError("API sidecar did not become ready before the startup deadline.");
  return false;
}

bool LocalSupervisor::WaitForWorkerStart() {
  const auto deadline = std::chrono::steady_clock::now() +
                        std::chrono::milliseconds(options_.worker_start_grace_ms);
  while (std::chrono::steady_clock::now() < deadline) {
    DWORD exit_code = STILL_ACTIVE;
    if (ProcessExited(worker_.process, &exit_code)) {
      SetError("Worker sidecar exited during startup (code " +
               std::to_string(exit_code) + ").");
      return false;
    }
    if (GetFileAttributesW(worker_ready_path_.c_str()) != INVALID_FILE_ATTRIBUTES) {
      return true;
    }
    Sleep(50);
  }
  SetError("Worker sidecar did not become ready before the startup deadline.");
  return false;
}

bool LocalSupervisor::Start() {
  if (started_.load()) return true;
  stopping_.store(false);
  {
    std::lock_guard<std::mutex> lock(state_mutex_);
    last_error_.clear();
  }

  if (!ResolveRuntimePaths() || !BuildRuntimeConfig()) {
    Stop();
    return false;
  }

  DeleteFileW(worker_ready_path_.c_str());
  DeleteFileW(stop_file_path_.c_str());

  bool api_ready = false;
  for (int attempt = 0; attempt < 3 && !api_ready; ++attempt) {
    if (!StartChild(api_path_, &api_)) break;
    api_ready = WaitForApiReady();
    if (api_ready) break;

    DWORD exit_code = STILL_ACTIVE;
    const bool exited_before_ready = ProcessExited(api_.process, &exit_code);
    StopChild(&api_, "API");
    if (!exited_before_ready || attempt == 2) break;

    // A sidecar that exits before /ready commonly failed to bind the chosen
    // port. Negotiate a fresh API/SSO pair before giving up.
    if (!BuildRuntimeConfig()) break;
  }
  if (!api_ready || !StartChild(worker_path_, &worker_) ||
      !WaitForWorkerStart()) {
    Stop();
    return false;
  }

  {
    std::lock_guard<std::mutex> lock(state_mutex_);
    last_error_.clear();
  }
  started_.store(true);
  monitor_thread_ = std::thread(&LocalSupervisor::MonitorLoop, this);
  return true;
}

void LocalSupervisor::MonitorLoop() {
  while (!stopping_.load()) {
    for (const auto& child : {std::pair<const char*, const ChildProcess*>{
                                  "API", &api_},
                              {"worker", &worker_}}) {
      DWORD exit_code = STILL_ACTIVE;
      if (ProcessExited(child.second->process, &exit_code)) {
        if (!stopping_.load()) {
          SetError(std::string(child.first) +
                   " sidecar exited unexpectedly (code " +
                   std::to_string(exit_code) + "). Restart the application to "
                   "recover queued work.");
        }
        return;
      }
    }
    Sleep(500);
  }
}

void LocalSupervisor::StopChild(ChildProcess* child, const char* label) {
  if (child->process == nullptr) return;

  // Console control is best-effort. Packaged sidecars currently have no
  // shutdown HTTP endpoint, so the bounded wait below is the safety net.
  GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT, child->process_id);
  const DWORD result =
      WaitForSingleObject(child->process, options_.shutdown_timeout_ms);
  if (result == WAIT_TIMEOUT) {
    WriteDiagnostic(std::string("Force terminating ") + label +
                    " sidecar after shutdown deadline.");
    TerminateProcess(child->process, 1);
    WaitForSingleObject(child->process, 1'000);
  }
  CloseHandle(child->process);
  child->process = nullptr;
  child->process_id = 0;
}

void LocalSupervisor::Stop() {
  stopping_.store(true);
  if (monitor_thread_.joinable()) monitor_thread_.join();
  if (!stop_file_path_.empty()) {
    std::error_code error;
    std::filesystem::create_directories(
        std::filesystem::path(stop_file_path_).parent_path(), error);
    std::ofstream stop_file(stop_file_path_, std::ios::out | std::ios::trunc);
    if (stop_file) stop_file << "stop\n";
  }
  StopChild(&worker_, "worker");
  StopChild(&api_, "API");
  started_.store(false);
  if (winsock_started_) {
    WSACleanup();
    winsock_started_ = false;
  }
}
