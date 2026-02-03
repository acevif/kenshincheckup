import Foundation
import kenshincheckupCore

@main
struct KenshinCheckupMain {
    static func main() {
        var args = CommandLine.arguments
        if args.count > 1 && args[1] == "help" {
            args[1] = "--help"
        }
        KenshinCheckupCommand.main(args)
    }
}
