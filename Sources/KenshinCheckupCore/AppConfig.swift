public struct AppConfig: Equatable {
    public let patterns: [String]

    public init(patterns: [String]) {
        self.patterns = patterns
    }
}
