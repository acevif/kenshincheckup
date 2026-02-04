import Foundation
import Logging

fileprivate let logger = Logger(label: "kenshin.plugin.chezmoi_unmanaged")

public struct ChezmoiUnmanagedPlugin: Plugin {
    public typealias ConfigType = ChezmoiUnmanagedConfig
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
        logger.debug("start chezmoi-unmanaged", metadata: ["patterns": "\(patterns)"])
        if patterns.isEmpty {
            logger.debug("skip: no patterns configured")
            return CheckResult(
                name: name,
                description: description,
                entries: [CheckEntry(status: .skip, message: "no patterns configured")]
            )
        }

        guard commandRunner.which("ghq") else {
            logger.debug("skip: ghq not found")
            return skippedResult("ghq not found")
        }
        guard commandRunner.which("chezmoi") else {
            logger.debug("skip: chezmoi not found")
            return skippedResult("chezmoi not found")
        }

        let ghqRoot = commandRunner.run(["ghq", "root"], cwd: nil)
        logger.debug(
            "ghq root",
            metadata: [
                "exitCode": "\(ghqRoot.exitCode.logDescription)",
                "stdout": "\(ghqRoot.stdout.trimmingCharacters(in: .whitespacesAndNewlines))",
                "stderr": "\(ghqRoot.stderr.trimmingCharacters(in: .whitespacesAndNewlines))",
            ]
        )
        guard ghqRoot.exitCode == .some(.success) else {
            return skippedResult("ghq root failed")
        }

        let rootPath = ghqRoot.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        if rootPath.isEmpty {
            return skippedResult("ghq root empty")
        }

        let rootURL = URL(fileURLWithPath: rootPath)
        let repos = findGitRepos(in: rootURL)
        logger.debug("repos discovered", metadata: ["count": "\(repos.count)"])

        var entries: [CheckEntry] = []
        for repo in repos {
            logger.debug("scan repo", metadata: ["repo": "\(repo.path)"])
            let matches = findMatchingFiles(in: repo, patterns: patterns)
            logger.debug("pattern matches", metadata: ["repo": "\(repo.path)", "count": "\(matches.count)"])
            for fileURL in matches {
                logger.debug("check file", metadata: ["file": "\(fileURL.path)"])
                let managed = commandRunner.run(["chezmoi", "source-path", fileURL.path], cwd: nil)
                switch managed.exitCode {
                case .some(.success):
                    logger.debug("managed file", metadata: ["file": "\(fileURL.path)"])
                    continue
                case .some(.failure):
                    logger.debug("unmanaged file", metadata: ["file": "\(fileURL.path)"])
                    let entry = CheckEntry(
                        status: .warn,
                        message: "unmanaged file",
                        details: ["repo: \(repo.path)", "file: \(fileURL.path)"]
                    )
                    entries.append(entry)
                default:
                    logger.debug(
                        "chezmoi command failed",
                        metadata: [
                            "file": "\(fileURL.path)",
                            "exitCode": "\(managed.exitCode.logDescription)",
                            "stderr": "\(managed.stderr)",
                        ]
                    )
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
        logger.debug("walk directory", metadata: ["path": "\(directory.path)"])
        guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: []) else {
            logger.debug("walk failed to list directory", metadata: ["path": "\(directory.path)"])
            return
        }

        if contents.contains(where: { $0.lastPathComponent == ".git" }) {
            logger.debug("repo found", metadata: ["path": "\(directory.path)"])
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
        logger.debug("enumerate repo", metadata: ["repo": "\(repoRoot.path)"])
        guard let enumerator = fileManager.enumerator(at: repoRoot, includingPropertiesForKeys: [.isDirectoryKey], options: [], errorHandler: nil) else {
            logger.debug("enumerator failed", metadata: ["repo": "\(repoRoot.path)"])
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
                logger.debug("pattern matched", metadata: ["repo": "\(repoRoot.path)", "path": "\(relative)"])
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
