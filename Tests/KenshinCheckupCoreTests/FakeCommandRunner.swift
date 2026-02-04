import Foundation
@testable import KenshinCheckupCore

final class FakeCommandRunner: CommandRunning {
    private let commandSeparator = "\u{0}"
    private let cwdSeparator = "\u{1}"

    var available: Set<String> = []
    private var stubs: [String: CommandResult] = [:]
    private(set) var calls: [FakeCommandRunnerCall] = []

    func which(_ name: String) -> Bool {
        available.contains(name)
    }

    func stub(_ command: [String], cwd: URL?, result: CommandResult) {
        stubs[key(for: command, cwd: cwd)] = result
    }

    func run(_ command: [String], cwd: URL?) -> CommandResult {
        let call = FakeCommandRunnerCall(command: command, cwd: cwd)
        calls.append(call)
        if let result = stubs[key(for: command, cwd: cwd)] {
            return result
        }
        return CommandResult(exitCode: .EXIT_FAILURE, stdout: "", stderr: "")
    }

    private func key(for command: [String], cwd: URL?) -> String {
        let cwdPart = cwd?.path ?? "<nil>"
        return command.joined(separator: commandSeparator) + cwdSeparator + cwdPart
    }
}
