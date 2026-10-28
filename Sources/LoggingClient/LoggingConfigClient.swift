import Dependencies
import DependenciesMacros
import FileLogger
import Foundation
import Logging

public enum LoggingError: Error {
  case unableToLocateCacheDirectory
}

@DependencyClient
public struct LoggingConfigClient: Sendable {
  public var logger: @Sendable () throws -> Logger
  public var logFileURL: @Sendable () throws -> URL
  public var maxLogFileSize: @Sendable () throws -> UInt64
  /// Extra log handlers that `LoggingClient.liveValue` adds for each logger label.
  ///
  /// Use it to plug in optional handlers, such as Pulse, without a hard dependency in this package.
  public var additionalLogHandlers: @Sendable (_ label: String) -> [any LogHandler] = { _ in [] }
}

extension LoggingConfigClient {
  /// Creates a configuration without additional log handlers.
  public init(
    logger: @escaping @Sendable () throws -> Logger,
    logFileURL: @escaping @Sendable () throws -> URL,
    maxLogFileSize: @escaping @Sendable () throws -> UInt64
  ) {
    self.init(
      logger: logger,
      logFileURL: logFileURL,
      maxLogFileSize: maxLogFileSize,
      additionalLogHandlers: { _ in [] }
    )
  }
}

extension DependencyValues {
  public var loggingConfigClient: LoggingConfigClient {
    get { self[LoggingConfigClient.self] }
    set { self[LoggingConfigClient.self] = newValue }
  }
}

extension LoggingConfigClient: TestDependencyKey {
  public static let previewValue = Self(
    logger: { Logger(label: "Preview") },
    logFileURL: { .init(string: "")! },
    maxLogFileSize: { 1024 }
  )

  public static let testValue = Self()

  public static let defaultValue = Self(
    logger: { Logger(label: "LoggingClient") },
    logFileURL: {
      guard let url = defaultLogFileURL else {
        throw LoggingError.unableToLocateCacheDirectory
      }

      return url
    },
    maxLogFileSize: { 1024 * 1024 * 10 }
  )
}

public let defaultLogFileURL = FileManager.default
  .urls(for: .cachesDirectory, in: .userDomainMask)
  .first?
  .appendingPathComponent("logs")
