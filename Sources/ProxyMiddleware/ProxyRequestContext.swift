import Hummingbird
import NIOCore

struct ProxyRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage
    /// The address from which the request originates.
    let remoteAddress: SocketAddress?

    init(source: ApplicationRequestContextSource) {
        self.coreContext = .init(source: source)
        self.remoteAddress = source.channel.remoteAddress
    }
}
