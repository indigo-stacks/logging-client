import ComposableArchitecture

extension Reducer {
  public func tcaLogs() -> some Reducer {
    #if DEBUG
      self._printChanges(.swiftLog(label: "TCA"))
    #else
      self
    #endif
  }
}
