import Foundation

public struct AppConfig: Equatable {
    public let patterns: [String]

    public init(patterns: [String]) {
        self.patterns = patterns
    }
}

public enum ConfigError: Error, Equatable {
    case missingFile
    case missingSection
    case missingPatterns
    case invalidFormat
}

public struct ConfigLoader {
    public static func load(from url: URL) throws -> AppConfig {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            throw ConfigError.missingFile
        }
        return try parse(text)
    }

    public static func parse(_ text: String) throws -> AppConfig {
        let targetSection = "[plugins.chezmoi_unmanaged]"
        var inSection = false
        var sectionLines: [String] = []

        let lines = text.split(whereSeparator: \.isNewline)
        for rawLine in lines {
            let line = stripComments(String(rawLine))
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                continue
            }
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                inSection = trimmed == targetSection
                continue
            }
            if inSection {
                sectionLines.append(trimmed)
            }
        }

        guard !sectionLines.isEmpty else {
            throw ConfigError.missingSection
        }

        let sectionText = sectionLines.joined(separator: "\n")
        guard let patterns = parsePatterns(from: sectionText) else {
            throw ConfigError.missingPatterns
        }

        return AppConfig(patterns: patterns)
    }

    private static func stripComments(_ line: String) -> String {
        if let hashIndex = line.firstIndex(of: "#") {
            return String(line[..<hashIndex])
        }
        if let slashIndex = line.range(of: "//")?.lowerBound {
            return String(line[..<slashIndex])
        }
        return line
    }

    private static func parsePatterns(from section: String) -> [String]? {
        let pattern = "patterns\\s*=\\s*\\[(.*)\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return nil
        }
        let range = NSRange(section.startIndex..<section.endIndex, in: section)
        guard let match = regex.firstMatch(in: section, options: [], range: range) else {
            return nil
        }
        guard match.numberOfRanges >= 2, let listRange = Range(match.range(at: 1), in: section) else {
            return nil
        }
        let listBody = section[listRange].trimmingCharacters(in: .whitespacesAndNewlines)
        if listBody.isEmpty {
            return []
        }

        let parts = listBody.split(separator: ",")
        var patterns: [String] = []
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"") else {
                return nil
            }
            let inner = trimmed.dropFirst().dropLast()
            let unescaped = inner
                .replacingOccurrences(of: "\\\\", with: "\\")
                .replacingOccurrences(of: "\\\"", with: "\"")
            patterns.append(unescaped)
        }

        return patterns
    }
}
