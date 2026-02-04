public struct CheckResult: Equatable {
    public let id: PluginID
    public let description: String
    public let entries: [CheckEntry]

    public init(id: PluginID, description: String, entries: [CheckEntry]) {
        self.id = id
        self.description = description
        self.entries = entries
    }

    public var hasFailure: Bool {
        entries.contains { $0.status.isFailure }
    }
}
