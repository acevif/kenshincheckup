import KenshinCheckupCore

public enum KenshinExitStatus: Equatable {
    case ok
    case hasWarnings
    case failed

    public static func from(_ finalStatus: KenshinFinalStatus) -> KenshinExitStatus {
        switch finalStatus {
        case .ok:
            .ok
        case .hasWarnings:
            .hasWarnings
        case .failed:
            .failed
        }
    }

    public var exitCode: Int32 {
        switch self {
        case .ok:
            0
        case .hasWarnings:
            1
        case .failed:
            70
        }
    }
}
