import Foundation

public protocol Plugin {
    associatedtype ConfigType
    var name: String { get }
    var description: String { get }
    func run() -> CheckResult
}
