import ConcurrencyExtras
import Foundation
import Logging
import Testing

@testable import LoggingClient

private final class RecordingLogHandler: LogHandler, Sendable {
  let messages = LockIsolated<[String]>([])

  var metadata: Logger.Metadata {
    get { [:] }
    set {}
  }

  var logLevel: Logger.Level {
    get { .trace }
    set {}
  }

  subscript(metadataKey _: String) -> Logger.Metadata.Value? {
    get { nil }
    set {}
  }

  func log(event: LogEvent) {
    messages.withValue { $0.append(event.message.description) }
  }
}

private func makeConfig(
  logFileURL: URL?,
  additionalLogHandlers: @escaping @Sendable (String) -> [any LogHandler]
) -> LoggingConfigClient {
  LoggingConfigClient(
    logger: { Logger(label: "Test") },
    logFileURL: {
      guard let logFileURL else { throw LoggingError.unableToLocateCacheDirectory }
      return logFileURL
    },
    maxLogFileSize: { 1024 * 1024 },
    additionalLogHandlers: additionalLogHandlers
  )
}

@Test func additionalLogHandlersDefaultsToEmpty() {
  let config = LoggingConfigClient(
    logger: { Logger(label: "Test") },
    logFileURL: { URL(fileURLWithPath: "/dev/null") },
    maxLogFileSize: { 1024 }
  )

  #expect(config.additionalLogHandlers("Test").isEmpty)
  #expect(LoggingConfigClient.defaultValue.additionalLogHandlers("Test").isEmpty)
}

@Test func additionalLogHandlersReceiveMessages() throws {
  let recorder = RecordingLogHandler()
  let directory = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  defer { try? FileManager.default.removeItem(at: directory) }

  let config = makeConfig(
    logFileURL: directory.appendingPathComponent("test.log"),
    additionalLogHandlers: { _ in [recorder] }
  )
  let logger = Logger(label: "Test") { makeLogHandler(label: $0, config: config) }
  logger.info("Hello")

  #expect(recorder.messages.value == ["Hello"])
}

@Test func additionalLogHandlersReceiveMessagesWithoutFileLogger() {
  let recorder = RecordingLogHandler()
  let config = makeConfig(logFileURL: nil, additionalLogHandlers: { _ in [recorder] })
  let logger = Logger(label: "Test") { makeLogHandler(label: $0, config: config) }
  logger.error("Failure")

  #expect(recorder.messages.value == ["Failure"])
}

@Test func additionalLogHandlersReceiveLabel() {
  let labels = LockIsolated<[String]>([])
  let config = makeConfig(
    logFileURL: nil,
    additionalLogHandlers: { label in
      labels.withValue { $0.append(label) }
      return []
    }
  )
  _ = makeLogHandler(label: "Feature", config: config)

  #expect(labels.value == ["Feature"])
}
