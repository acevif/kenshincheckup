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
