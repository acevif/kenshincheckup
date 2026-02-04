import Tagged

public enum ExitCodeTag {}

public typealias ExitCode = Tagged<ExitCodeTag, Int32>

public extension ExitCode {
    static let success = ExitCode(rawValue: 0)
    static let failure = ExitCode(rawValue: 1)
}

extension ExitCode: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        "ExitCode(\(rawValue))"
    }
}

public extension Optional where Wrapped == ExitCode {
    var logDescription: String {
        switch self {
        case .some(let value):
            return value.description
        case .none:
            return "nil"
        }
    }
}
