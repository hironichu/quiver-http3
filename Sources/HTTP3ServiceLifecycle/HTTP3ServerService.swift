import HTTP3
import ServiceLifecycle

/// Runs an `HTTP3Server` as a Swift Service Lifecycle service.
///
/// Use this adapter when an executable wants `ServiceGroup` to own startup,
/// signal handling, and graceful shutdown while keeping Quiver's core server
/// APIs unchanged.
public struct HTTP3ServerService: Service, Sendable {
    public typealias Start = @Sendable (HTTP3Server) async throws -> Void

    public enum StartupMode: Sendable, Hashable {
        /// Start the server with `HTTP3Server.listen()`.
        case listen

        /// Start the server with `HTTP3Server.listenAll()`.
        case listenAll
    }

    public let server: HTTP3Server

    private let start: Start
    private let shutdownGracePeriod: Duration

    /// Creates a service that starts the server with the selected startup mode.
    ///
    /// The server must have been created with `HTTP3ServerOptions`.
    public init(
        server: HTTP3Server,
        startupMode: StartupMode = .listen,
        shutdownGracePeriod: Duration = .seconds(5)
    ) {
        self.init(
            server: server,
            shutdownGracePeriod: shutdownGracePeriod
        ) { server in
            switch startupMode {
            case .listen:
                try await server.listen()
            case .listenAll:
                try await server.listenAll()
            }
        }
    }

    /// Creates a service with a custom startup operation.
    ///
    /// Use this initializer for advanced startup paths, such as calling
    /// `listen(host:port:quicConfiguration:)` or `serve(connectionSource:)`.
    public init(
        server: HTTP3Server,
        shutdownGracePeriod: Duration = .seconds(5),
        start: @escaping Start
    ) {
        self.server = server
        self.shutdownGracePeriod = shutdownGracePeriod
        self.start = start
    }

    public func run() async throws {
        let server = self.server
        let shutdownGracePeriod = self.shutdownGracePeriod

        try await withTaskCancellationHandler {
            try await start(server)
        } onCancel: {
            Task {
                await server.stop(gracePeriod: shutdownGracePeriod)
            }
        }
    }
}