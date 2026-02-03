import Foundation

public struct ChezmoiUnmanagedPlugin: Plugin {
    public let name: String = "doctor_chezmoi_unmanaged"
    public let description: String = "Detect unmanaged config files."

    private let patterns: [String]
    private let commandRunner: CommandRunning
    private let fileManager: FileManager

    public init(patterns: [String], commandRunner: CommandRunning, fileManager: FileManager = .default) {
        self.patterns = patterns
        self.commandRunner = commandRunner
        self.fileManager = fileManager
    }

    public func run() -> CheckResult {
        if patterns.isEmpty {
            return CheckResult(
                name: name,
                description: description,
                entries: [CheckEntry(status: .skip, message: "no patterns configured")]
            )
        }

        guard commandRunner.which("ghq") else {
            return skippedResult("ghq not found")
        }
        guard commandRunner.which("chezmoi") else {
            return skippedResult("chezmoi not found")
        }

        let ghqRoot = commandRunner.run(["ghq", "root"], cwd: nil)
        guard ghqRoot.exitCode == 0 else {
            return skippedResult("ghq root failed")
        }

        let rootPath = ghqRoot.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        if rootPath.isEmpty {
            return skippedResult("ghq root empty")
        }

        let rootURL = URL(fileURLWithPath: rootPath)
        let repos = findGitRepos(in: rootURL)

        var entries: [CheckEntry] = []
        for repo in repos {
            let matches = findMatchingFiles(in: repo, patterns: patterns)
            for fileURL in matches {
                let managed = commandRunner.run(["chezmoi", "source-path", fileURL.path], cwd: nil)
                switch managed.exitCode {
                case .some(0):
                    continue
                case .some(1):
                    let entry = CheckEntry(
                        status: .warn,
                        message: "unmanaged file",
                        details: ["repo: \(repo.path)", "file: \(fileURL.path)"]
                    )
                    entries.append(entry)
                default:
                    let entry = CheckEntry(
                        status: .fail,
                        message: "chezmoi command failed",
                        details: [
                            "repo: \(repo.path)",
                            "file: \(fileURL.path)",
                            "error: \(managed.stderr)",
                        ]
                    )
                    return CheckResult(name: name, description: description, entries: [entry])
                }
            }
        }

        if entries.isEmpty {
            entries.append(CheckEntry(status: .ok, message: "no unmanaged files"))
        }

        return CheckResult(name: name, description: description, entries: entries)
    }

    private func skippedResult(_ reason: String) -> CheckResult {
        CheckResult(name: name, description: description, entries: [CheckEntry(status: .skip, message: reason)])
    }

    private func findGitRepos(in root: URL) -> [URL] {
        var repos: [URL] = []
        walk(directory: root, repos: &repos)
        return repos
    }

    private func walk(directory: URL, repos: inout [URL]) {
        guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: []) else {
            return
        }

        if contents.contains(where: { $0.lastPathComponent == ".git" }) {
            repos.append(directory)
            return
        }

        for item in contents {
            let resourceValues = try? item.resourceValues(forKeys: [.isDirectoryKey])
            if resourceValues?.isDirectory == true {
                walk(directory: item, repos: &repos)
            }
        }
    }

    private func findMatchingFiles(in repoRoot: URL, patterns: [String]) -> [URL] {
        guard let enumerator = fileManager.enumerator(at: repoRoot, includingPropertiesForKeys: [.isDirectoryKey], options: [], errorHandler: nil) else {
            return []
        }
        var matches: [URL] = []
        for case let fileURL as URL in enumerator {
            let relative = relativePath(from: repoRoot, to: fileURL)
            if relative.hasPrefix(".git/") || relative == ".git" {
                enumerator.skipDescendants()
                continue
            }
            let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey])
            if resourceValues?.isDirectory == true {
                continue
            }
            if patterns.contains(where: { PathMatcher.matches($0, relative) }) {
                matches.append(fileURL)
            }
        }
        return matches
    }

    private func relativePath(from base: URL, to file: URL) -> String {
        let basePath = base.standardizedFileURL.path
        let filePath = file.standardizedFileURL.path
        let prefix = basePath.hasSuffix("/") ? basePath : basePath + "/"
        if filePath.hasPrefix(prefix) {
            return String(filePath.dropFirst(prefix.count))
        }
        return filePath
    }
}
