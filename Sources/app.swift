import Hummingbird
import ArgumentParser

@main
struct ServerArguments: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8081

    @Option(name: .shortAndLong)
    var serverName: String = "Hummingbird"

    @Option(name: .shortAndLong, help: "The target server to forward requests to")
    var target: String = "https://localhost:8080"

    @Option(name: .shortAndLong, help: "If provided, set this API key as the Authorization header on requests forwarded by the proxy")
    var apiKey: String?

    func run() async throws {
        let app = buildApplication(self)
        try await app.runService()
    }
}
