public struct AppConfig: Equatable {
    public let chezmoiUnmanaged: ChezmoiUnmanagedConfig

    public init(chezmoiUnmanaged: ChezmoiUnmanagedConfig) {
        self.chezmoiUnmanaged = chezmoiUnmanaged
    }
}
