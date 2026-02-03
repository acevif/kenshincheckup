import Foundation

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

public struct CheckResult: Equatable {
    public let name: String
    public let description: String
    public let entries: [CheckEntry]

    public init(name: String, description: String, entries: [CheckEntry]) {
        self.name = name
        self.description = description
        self.entries = entries
    }

    public var hasFailure: Bool {
        entries.contains { $0.status.isFailure }
    }
}

public struct OutputFormatter {
    public static func render(_ result: CheckResult) -> [String] {
        var lines: [String] = []
        lines.append("== \(result.name) ==")
        let descriptionLines = result.description.split(separator: "\n").map { String($0) }
        lines.append(contentsOf: descriptionLines)

        for entry in result.entries {
            let prefixText = prefix(for: entry.status)
            let separator = prefixText.hasSuffix(" ") ? "" : " "
            lines.append(prefixText + separator + entry.message)
            for detail in entry.details {
                lines.append("  - \(detail)")
            }
        }

        return lines
    }

    public static func write(_ result: CheckResult) {
        for line in render(result) {
            print(line)
        }
    }

    public static func exitCode(for results: [CheckResult]) -> Int32 {
        let hasFailure = results.contains { $0.hasFailure }
        return hasFailure ? 1 : 0
    }

    private static func prefix(for status: CheckStatus) -> String {
        switch status {
        case .ok:
            return "[OK]  "
        case .warn:
            return "[WARN]"
        case .fail:
            return "[FAIL]"
        case .skip:
            return "[SKIP]"
        }
    }
}
