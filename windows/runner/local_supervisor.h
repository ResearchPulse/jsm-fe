#ifndef RUNNER_LOCAL_SUPERVISOR_H_
#define RUNNER_LOCAL_SUPERVISOR_H_

#include <windows.h>

#include <atomic>
#include <chrono>
#include <cstdint>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

// Owns the two bundled desktop sidecars for the lifetime of the Flutter
// window. This class deliberately has no Flutter dependency so it can be
// exercised by a small native harness with stub executables.
class LocalSupervisor {
 public:
  struct Options {
    std::wstring runtime_root;
    std::wstring api_executable = L"jsm-api.exe";
    std::wstring worker_executable = L"jsm-worker.exe";
    std::string readiness_path = "/ready";
    DWORD readiness_timeout_ms = 30'000;
    // PyInstaller startup includes Python import time and local SQLite/storage
    // initialization. Keep this independent from the API readiness timeout so
    // slower Windows machines do not get a false worker-start failure.
    DWORD worker_start_grace_ms = 15'000;
    DWORD shutdown_timeout_ms = 3'000;
  };

  struct RuntimeConfig {
    uint16_t api_port = 0;
    uint16_t sso_callback_port = 0;
    std::string api_base_url;
    std::string profile = "desktop";
    std::string runtime_token;
  };

  LocalSupervisor();
  explicit LocalSupervisor(Options options);
  ~LocalSupervisor();

  LocalSupervisor(const LocalSupervisor&) = delete;
  LocalSupervisor& operator=(const LocalSupervisor&) = delete;

  bool Start();
  void Stop();

  bool IsRunning() const { return started_.load(); }
  RuntimeConfig runtime_config() const;
  std::string LastError() const;
  std::vector<std::string> DartEntrypointArguments() const;

 private:
  struct ChildProcess {
    HANDLE process = nullptr;
    DWORD process_id = 0;
    std::wstring executable;
  };

  bool ResolveRuntimePaths();
  bool BuildRuntimeConfig();
  bool StartChild(const std::wstring& executable, ChildProcess* child);
  bool WaitForApiReady();
  bool WaitForWorkerStart();
  bool ProbeReady();
  void MonitorLoop();
  void StopChild(ChildProcess* child, const char* label);
  void SetError(std::string message);
  void WriteDiagnostic(const std::string& message) const;

  Options options_;
  std::wstring api_path_;
  std::wstring worker_path_;
  std::wstring worker_ready_path_;
  std::wstring stop_file_path_;
  std::wstring data_root_;
  RuntimeConfig runtime_config_;
  ChildProcess api_;
  ChildProcess worker_;
  std::atomic<bool> started_{false};
  std::atomic<bool> stopping_{false};
  std::thread monitor_thread_;
  mutable std::mutex state_mutex_;
  std::string last_error_;
  bool winsock_started_ = false;
};

#endif  // RUNNER_LOCAL_SUPERVISOR_H_
