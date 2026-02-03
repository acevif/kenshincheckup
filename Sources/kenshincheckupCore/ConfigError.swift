public enum ConfigError: Error, Equatable {
    case missingFile
    case missingSection
    case missingPatterns
    case invalidFormat
}
