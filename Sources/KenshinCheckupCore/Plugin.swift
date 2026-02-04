import Foundation

public protocol Plugin {
    associatedtype ConfigType
    var id: PluginID { get }
    var description: String { get }
    func run() -> CheckResult
}
