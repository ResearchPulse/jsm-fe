#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <algorithm>

#include "flutter_window.h"
#include "local_supervisor.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  LocalSupervisor supervisor;
  if (!supervisor.Start()) {
    const std::string error = supervisor.LastError();
    const int size = MultiByteToWideChar(CP_UTF8, 0, error.data(),
                                         static_cast<int>(error.size()),
                                         nullptr, 0);
    std::wstring wide_error(size, L'\0');
    MultiByteToWideChar(CP_UTF8, 0, error.data(),
                        static_cast<int>(error.size()), wide_error.data(), size);
    MessageBoxW(nullptr, wide_error.c_str(), L"JSM desktop runtime error",
                MB_OK | MB_ICONERROR);
    ::CoUninitialize();
    return EXIT_FAILURE;
  }

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  const auto runtime_arguments = supervisor.DartEntrypointArguments();
  command_line_arguments.insert(command_line_arguments.end(),
                                runtime_arguments.begin(),
                                runtime_arguments.end());
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project, &supervisor);
  RECT work_area{};
  SystemParametersInfoW(SPI_GETWORKAREA, 0, &work_area, 0);
  constexpr int kDefaultWidth = 1280;
  constexpr int kDefaultHeight = 800;
  const int origin_x = std::max(0L, (work_area.right - work_area.left -
                                    kDefaultWidth) /
                                       2 +
                                   work_area.left);
  const int origin_y = std::max(0L, (work_area.bottom - work_area.top -
                                    kDefaultHeight) /
                                       2 +
                                   work_area.top);
  Win32Window::Point origin(origin_x, origin_y);
  Win32Window::Size size(kDefaultWidth, kDefaultHeight);
  if (!window.Create(L"HyperData Lab - Journal System Miner", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
