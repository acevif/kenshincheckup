import Foundation

public protocol Plugin {
    var name: String { get }
    var description: String { get }
    func run() -> CheckResult
}
