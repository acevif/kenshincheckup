import Foundation

public struct OutputFormatter {
    public static func render(_ result: CheckResult) -> [String] {
        var lines: [String] = []
        lines.append("== \(result.id) ==")
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

    public static func exitCode(for results: [CheckResult]) -> ExitCode {
        let hasFailure = results.contains { $0.hasFailure }
        return hasFailure ? .failure : .success
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
