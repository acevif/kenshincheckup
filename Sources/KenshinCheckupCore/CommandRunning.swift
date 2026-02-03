import Foundation

public protocol CommandRunning {
    func which(_ name: String) -> Bool
    func run(_ command: [String], cwd: URL?) -> CommandResult
}
