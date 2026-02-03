public struct CheckResult: Equatable {
    public let name: String
    public let description: String
    public let entries: [CheckEntry]

    public init(name: String, description: String, entries: [CheckEntry]) {
        self.name = name
        self.description = description
        self.entries = entries
    }

    public var hasFailure: Bool {
        entries.contains { $0.status.isFailure }
    }
}
