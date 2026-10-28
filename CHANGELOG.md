# Changelog

## Unreleased (proposed 3.0.0)

### Breaking

- Remove the `PulseLogHandler` (Pulse) dependency. `LoggingClient` now depends only on Foundation,
  swift-log, swift-file-logger, swift-dependencies, and the Composable Architecture.
  Apps can ship Pulse in Debug builds only, and a Release build without Pulse no longer crashes at launch.
- `LoggingClient.liveValue` no longer adds a Pulse `PersistentLogHandler` in DEBUG builds.
  To keep Pulse logs, supply the handler through `LoggingConfigClient.additionalLogHandlers`.
  See "Migrating from 2.x" in the README.

### Added

- `LoggingConfigClient.additionalLogHandlers`: extra swift-log handlers for each logger label.
  `LoggingClient.liveValue` adds them in all build configurations. The default is no handlers.
  The existing `LoggingConfigClient(logger:logFileURL:maxLogFileSize:)` initializer still compiles.

### Changed

- Update `Package.resolved` to the Composable Architecture 1.26.2 and current dependency versions.
  The previous pin (1.23.1) does not compile with Xcode 26.6 and later.
- Rename `View+PulseLogs.swift` to `Reducer+TCALogs.swift`. The `tcaLogs()` API does not change.
