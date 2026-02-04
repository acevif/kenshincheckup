public struct CheckEntry: Equatable {
    public let result: CheckupResult
    public let message: String
    public let details: [String]

    public init(result: CheckupResult, message: String, details: [String] = []) {
        self.result = result
        self.message = message
        self.details = details
    }
}
