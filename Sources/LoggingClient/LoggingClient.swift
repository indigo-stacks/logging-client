import Dependencies
import DependenciesMacros
import FileLogger
import Foundation
import Logging

@DependencyClient
public struct LoggingClient: Sendable {
  public var logTrace:
    @Sendable (
      _ message: String,
      _ function: String,
      _ file: String,
      _ line: UInt
    ) async throws -> Void

  public var logDebug:
    @Sendable (
      _ message: String,
      _ function: String,
      _ file: String,
      _ line: UInt
    ) async throws -> Void

  public var logInfo:
    @Sendable (
      _ message: String,
      _ function: String,
      _ file: String,
      _ line: UInt
    ) async throws -> Void

  public var logNotice:
    @Sendable (
      _ message: String,
      _ function: String,
      _ file: String,
      _ line: UInt
    ) async throws -> Void

  public var logWarning:
    @Sendable (
      _ message: String,
      _ function: String,
      _ file: String,
      _ line: UInt
    ) async throws -> Void

  public var logError:
    @Sendable (
      _ message: String,
      _ function: String,
      _ file: String,
      _ line: UInt
    ) async throws -> Void

  public var logCritical:
    @Sendable (
      _ message: String,
      _ function: String,
      _ file: String,
      _ line: UInt
    ) async throws -> Void
}

extension LoggingClient {
  @inlinable
  public func trace(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
  ) async throws {
    try await logTrace(message, function, file, line)
  }

  @inlinable
  public func debug(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
  ) async throws {
    try await logDebug(message, function, file, line)
  }

  @inlinable
  public func info(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
  ) async throws {
    try await logInfo(message, function, file, line)
  }

  @inlinable
  public func notice(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
  ) async throws {
    try await logNotice(message, function, file, line)
  }

  @inlinable
  public func warning(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
  ) async throws {
    try await logWarning(message, function, file, line)
  }

  @inlinable
  public func error(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
  ) async throws {
    try await logError(message, function, file, line)
  }

  @inlinable
  public func critical(
    _ message: String,
    function: String = #function,
    file: String = #file,
    line: UInt = #line
  ) async throws {
    try await logCritical(message, function, file, line)
  }
}

extension DependencyValues {
  public var loggingClient: LoggingClient {
    get { self[LoggingClient.self] }
    set { self[LoggingClient.self] = newValue }
  }
}

extension LoggingClient: TestDependencyKey {
  public static let previewValue = Self(
    logTrace: { _, _, _, _ in },
    logDebug: { _, _, _, _ in },
    logInfo: { _, _, _, _ in },
    logNotice: { _, _, _, _ in },
    logWarning: { _, _, _, _ in },
    logError: { _, _, _, _ in },
    logCritical: { _, _, _, _ in }
  )

  public static let testValue = Self()
}

extension LoggingClient: DependencyKey {
  public static let liveValue = { () -> Self in
    @Dependency(\.loggingConfigClient) var config

    LoggingSystem.bootstrap { label in
      makeLogHandler(label: label, config: config)
    }

    return Self(
      logTrace: { message, function, file, line in
        try config.logger().trace(
          .init(stringLiteral: message),
          file: file,
          function: function,
          line: line
        )
      },
      logDebug: { message, function, file, line in
        try config.logger().debug(
          .init(stringLiteral: message),
          file: file,
          function: function,
          line: line
        )
      },
      logInfo: { message, function, file, line in
        try config.logger().info(
          .init(stringLiteral: message),
          file: file,
          function: function,
          line: line
        )
      },
      logNotice: { message, function, file, line in
        try config.logger().notice(
          .init(stringLiteral: message),
          file: file,
          function: function,
          line: line
        )
      },
      logWarning: { message, function, file, line in
        try config.logger().warning(
          .init(stringLiteral: message),
          file: file,
          function: function,
          line: line
        )
      },
      logError: { message, function, file, line in
        try config.logger().error(
          .init(stringLiteral: message),
          file: file,
          function: function,
          line: line
        )
      },
      logCritical: { message, function, file, line in
        try config.logger().critical(
          .init(stringLiteral: message),
          file: file,
          function: function,
          line: line
        )
      }
    )
  }()
}

/// Builds the log handler that `LoggingClient.liveValue` bootstraps for each label.
///
/// In DEBUG builds, it combines console, file, and `additionalLogHandlers` output.
/// In other builds, it uses the file handler and `additionalLogHandlers`.
/// If the file handler cannot be created, it uses console and `additionalLogHandlers` output.
func makeLogHandler(label: String, config: LoggingConfigClient) -> any LogHandler {
  let consoleLogHandler = StreamLogHandler.standardOutput(label: label)
  let additionalLogHandlers = config.additionalLogHandlers(label)

  do {
    let fileLogHandler = try FileLogger(
      label: label,
      fileURL: try config.logFileURL(),
      maxFileSize: try config.maxLogFileSize()
    )

    #if DEBUG
      return MultiplexLogHandler([consoleLogHandler, fileLogHandler] + additionalLogHandlers)
    #else
      return additionalLogHandlers.isEmpty
        ? fileLogHandler
        : MultiplexLogHandler([fileLogHandler] + additionalLogHandlers)
    #endif
  } catch {
    return additionalLogHandlers.isEmpty
      ? consoleLogHandler
      : MultiplexLogHandler([consoleLogHandler] + additionalLogHandlers)
  }
}
