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

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: ExitCode?) {
        appendLiteral(value?.description ?? "nil")
    }
}
