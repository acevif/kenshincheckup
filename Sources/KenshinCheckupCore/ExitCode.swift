import Tagged

public enum ExitCodeTag {}

public typealias ExitCode = Tagged<ExitCodeTag, Int32>

public extension ExitCode {
    static let EXIT_SUCCESS = ExitCode(rawValue: 0)
    static let EXIT_FAILURE = ExitCode(rawValue: 1)
}

extension ExitCode: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        "ExitCode(\(rawValue))"
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: ExitCode?) {
        appendLiteral(value?.description ?? "nil")
    }
}
