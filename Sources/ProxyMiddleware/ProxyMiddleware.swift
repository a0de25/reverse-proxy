import AsyncHTTPClient
import Hummingbird
import NIOCore

struct ProxyMiddleware: RouterMiddleware {
    typealias Context = ProxyRequestContext

    struct Configuration {
        /// The target server to forward requests to
        let target: String
        /// Auth token to add as `Authorization` header on requests being forwarded
        let authToken: String?
    }

    private let client: HTTPClient
    private let config: Configuration

    init(client: HTTPClient, config: Configuration) {
        self.client = client
        self.config = config
    }

    func handle(_ input: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        guard let response = try await forward(request: input, using: config, context: context) else {
            return try await next(input, context)
        }
        return response
    }

    private func forward(request: Request, using config: Configuration, context: Context) async throws -> Response? {
        context.logger.debug("Forwarding to: \(request.uri)")

        // Setup a basic copy of the inbound request we are going to forward
        var forwardedRequest = HTTPClientRequest(url: "\(config.target)\(request.uri)")
        forwardedRequest.method = .init(request.method)
        forwardedRequest.headers = .init(request.headers)
        forwardedRequest.body = .stream(request.body, length: request.headers.contentLength)

        // Add an `Authorization` header so the reciever can verify our access to their API.
        if let authHeader = config.authToken {
            forwardedRequest.headers.add(name: "Authorization", value: authHeader)
        }

        // Add a `Forwarded` header so the reciever can see where the request is coming from
        forwardedRequest.headers.add(name: "Forwarded", value: "for=\(context.forwardedForHeaderValue)")

        async let response = client.execute(forwardedRequest, timeout: .seconds(10), logger: context.logger)
        return try await Response(httpClientResponse: response)
    }
}

private extension Response {
    init(httpClientResponse response: HTTPClientResponse) {
        self.init(
            status: .init(code: Int(response.status.code), reasonPhrase: response.status.reasonPhrase),
            headers: .init(response.headers, splitCookie: false),
            body: .init(asyncSequence: response.body)
        )
    }
}

private extension HTTPFields {
    var contentLength: HTTPClientRequest.Body.Length {
        guard let headerValue = self[.contentLength], let contentLength = Int64(headerValue) else {
            return .unknown
        }
        
        return .known(contentLength)
    }
}

private extension ProxyRequestContext {
    /// The interface where the request came in to the proxy server.
    ///
    /// The identifier can be:
    ///  -  an obfuscated identifier (such as "hidden" or "secret"). This should be treated as the default.
    ///  - an IP address (v4 or v6, optionally with a port, and ipv6 quoted and enclosed in square brackets)
    ///  - "unknown" when the preceding entity is not known (and you still want to indicate that forwarding of the request was made)
    ///
    /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Forwarded
    var forwardedForHeaderValue: String {
        switch (remoteAddress, remoteAddress?.ipAddress) {
        case (.v4, .some(let v4Address)):
            v4Address
        case (.v6, .some(let v6Address)):
            "\"[\(v6Address)]\""
        default:
            "hidden"
        }
    }
}
