# LocalSupervisor native harness

`LocalSupervisor` is intentionally independent of Flutter. A Windows native
test can construct it with `LocalSupervisor::Options{runtime_root = ...}` and
place two stub executables at:

```text
<runtime_root>/jsm-api/jsm-api.exe
<runtime_root>/jsm-worker/jsm-worker.exe
```

The API stub should bind loopback on `JSM_API_PORT`, record its startup marker,
return `HTTP/1.1 200` for `GET /ready`, and remain alive. The worker stub should
record its startup marker, remain alive, and exit when the harness terminates
it. Both stubs can assert `RUNTIME_PROFILE=desktop`, `JSM_RUNTIME_TOKEN`, and
`APP_DATA_DIR`; the API receives the same token as `X-JSM-Runtime-Token` on the
readiness probe.

The native assertions should cover:

1. API launch precedes worker launch, and Flutter arguments contain distinct
   API and SSO callback ports plus the desktop profile.
2. API readiness timeout reports an actionable error and never launches the
   worker.
3. A port collision causes a different negotiated loopback port to be passed
   to the API and Dart.
4. An API/worker crash is recorded in `%LOCALAPPDATA%\JSM\logs\desktop-supervisor.log`.
5. `Stop()` waits for the worker before the API and force-terminates only after
   the bounded shutdown deadline.

The current workspace does not include a Visual Studio native test project or
packaged sidecar stubs, so this README is the executable contract for the
future Windows integration gate. Dart covers the shared config/readiness seam
in `test/core/desktop_runtime_config_test.dart` and
`test/desktop/sidecar_lifecycle_test.dart`.
