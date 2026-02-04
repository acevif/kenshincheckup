import Foundation

public enum OutputFormatter {
    public static func render(_ result: CheckResult) -> [String] {
        var lines: [String] = []
        lines.append("== \(result.id) ==")
        let descriptionLines: [String] = result.description
            .split(separator: "\n")
            .map { .init($0) }
        lines.append(contentsOf: descriptionLines)

        for entry in result.entries {
            let prefixText = prefix(for: entry.result)
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

    private static func prefix(for result: CheckupResult) -> String {
        switch result {
        case .outcome(.ok):
            "[OK]  "
        case .outcome(.warn):
            "[WARN]"
        case .failed:
            "[FAIL]"
        case .skipped:
            "[SKIP]"
        }
    }
}
