# 🪻 logging-client

A dependency client that handles file logs in apps using the Swift Composable Architecture (TCA).
It is part of the [Indigo Stack](https://indigostack.org).

## Usage

- `logTrace` Logs trace-level messages, typically used for detailed debugging information.
- `logVerbose` Logs verbose-level messages, providing more detailed information than debug logs.
- `logDebug` Logs debug-level messages, useful for debugging during development.
- `logInfo` Logs informational messages, typically used to report normal but significant events.
- `logNotice` Logs notice-level messages, indicating normal but noteworthy conditions.
- `logWarning` Logs warning-level messages, indicating potential issues or important situations that are not errors.
- `logError` Logs error-level messages, indicating errors that might still allow the application to continue running.
- `logCritical` Logs critical-level messages, indicating severe errors that will presumably lead the application to abort.

To get started, you need to configure the logger using the `LoggingConfigClient`.
You can achieve that in your app by implementing a `liveValue` from scratch, or using the
provided `defaultValue` that comes with this library.

```swift
extension LoggingConfigClient: DependencyValue {
  static let liveValue = defaultValue
}
```

The default value uses a `LoggingClient` label, saves the log files in the caches
directory, and caps the size of a logs file to 10mb.

### Additional log handlers

`LoggingClient.liveValue` sends each message to the console (DEBUG builds only), the log file,
and the handlers that `LoggingConfigClient.additionalLogHandlers` returns.
The library adds these handlers in all build configurations,
so use `#if DEBUG` in your app to limit a handler to Debug builds.

## Migrating from 2.x

Version 3 removes the Pulse dependency. In 2.x, DEBUG builds sent logs to Pulse automatically.
To keep that behavior, add [PulseLogHandler](https://github.com/kean/PulseLogHandler) to your app
(for example, to the Debug configuration only) and supply its handler:

```swift
import Dependencies
import LoggingClient

#if DEBUG
  import PulseLogHandler
#endif

extension LoggingConfigClient: @retroactive DependencyKey {
  public static let liveValue: Self = {
    var config = Self.defaultValue
    #if DEBUG
      config.additionalLogHandlers = { label in [PersistentLogHandler(label: label)] }
    #endif
    return config
  }()
}
```

If you do not use Pulse, you do not need to change your code.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details
