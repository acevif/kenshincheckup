import Foundation

public enum CheckStatus: String, Equatable {
    case ok
    case warn
    case fail
    case skip

    var isFailure: Bool {
        switch self {
        case .warn, .fail:
            return true
        case .ok, .skip:
            return false
        }
    }
}

public struct CheckEntry: Equatable {
    public let status: CheckStatus
    public let message: String
    public let details: [String]

    public init(status: CheckStatus, message: String, details: [String] = []) {
        self.status = status
        self.message = message
        self.details = details
    }
}

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
