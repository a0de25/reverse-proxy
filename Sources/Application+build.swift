import Hummingbird
import AsyncHTTPClient
import NIOCore
import NIOPosix
import Logging

func buildApplication(_ args: ServerArguments) -> some ApplicationProtocol {
    let httpClient = HTTPClient()

    // The middleware which will handle and forward incoming requests to the proxy server
    let proxyMiddleware = ProxyMiddleware(
        client: httpClient,
        config: ProxyMiddleware.Configuration(
            target: args.target,
            authToken: args.apiKey
        )
    )

    let router = Router(context: ProxyMiddleware.Context.self)
    router.add(middleware: proxyMiddleware)

    var app = Application(
        router: router,
        configuration: ApplicationConfiguration(
            address: .hostname(args.hostname, port: args.port),
            serverName: args.serverName
        ),
        logger: Logger(label: "reverse-proxy")
    )

    // This service waits for a graceful shutdown signal to shut down the client and release its resources
    // before the program exits.
    let httpClientShutdownService = HTTPClientShutdownService(client: httpClient)
    app.addServices(httpClientShutdownService)

    return app
}
