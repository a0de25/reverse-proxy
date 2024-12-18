import AsyncHTTPClient
import ServiceLifecycle

/// A service lifecycle service which handles shutting down a `HTTPClient` on graceful shutdown.
struct HTTPClientShutdownService: Service {
    let client: HTTPClient

    func run() async throws {
        try? await gracefulShutdown()
        try await client.shutdown()
    }
}
