import Foundation

public struct PathMatcher {
    public static func matches(_ pattern: String, _ path: String) -> Bool {
        if pattern == path {
            return true
        }
        let regexPattern = toRegex(pattern)
        guard let regex: NSRegularExpression = try? .init(pattern: regexPattern, options: []) else {
            return false
        }
        let range: NSRange = .init(path.startIndex..<path.endIndex, in: path)
        return regex.firstMatch(in: path, options: [], range: range) != nil
    }

    private static func toRegex(_ pattern: String) -> String {
        var regex = "^"
        var index = pattern.startIndex
        while index < pattern.endIndex {
            let char = pattern[index]
            if char == "*" {
                let nextIndex = pattern.index(after: index)
                if nextIndex < pattern.endIndex, pattern[nextIndex] == "*" {
                    regex += ".*"
                    index = pattern.index(after: nextIndex)
                    continue
                }
                regex += "[^/]*"
                index = nextIndex
                continue
            }
            if char == "?" {
                regex += "[^/]"
                index = pattern.index(after: index)
                continue
            }
            if "\\.^$+{}()|[]".contains(char) {
                regex += "\\\\"
            }
            regex.append(char)
            index = pattern.index(after: index)
        }
        regex += "$"
        return regex
    }
}
