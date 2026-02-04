import KenshinCheckupCore

public enum CheckupExitStatus: Equatable {
    case ok
    case warn
    case failed

    public static func from(_ results: [CheckResult]) -> CheckupExitStatus {
        let entries = results.flatMap(\.entries)
        if entries.contains(where: { $0.result == .failed }) {
            return .failed
        }
        if entries.contains(where: { if case .outcome(.warn) = $0.result { true } else { false } }) {
            return .warn
        }
        return .ok
    }

    public var exitCode: Int32 {
        switch self {
        case .ok:
            0
        case .warn:
            1
        case .failed:
            70
        }
    }
}
