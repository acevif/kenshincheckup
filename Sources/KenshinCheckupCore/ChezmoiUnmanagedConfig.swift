public struct ChezmoiUnmanagedConfig: Decodable {
    public let patterns: [String]?

    public init(patterns: [String]?) {
        self.patterns = patterns
    }
}
