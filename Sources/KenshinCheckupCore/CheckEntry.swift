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
