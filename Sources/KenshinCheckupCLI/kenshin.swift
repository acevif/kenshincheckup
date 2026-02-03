import Foundation
import KenshinCheckupCore

@main
struct KenshinMain {
    static func main() {
        let args = CommandLine.arguments
        KenshinCheckupCommand.main(Array(args.dropFirst()))
    }
}
