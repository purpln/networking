import LibC

public enum SocketFamily: Sendable {
#if !os(Windows)
    case unix
#endif
    case ipv4, ipv6
}

extension SocketFamily {
    var rawValue: CInt {
        switch self {
#if !os(Windows)
        case .unix: return PF_LOCAL
#endif
        case .ipv4: return PF_INET
        case .ipv6: return PF_INET6
        }
    }
}
