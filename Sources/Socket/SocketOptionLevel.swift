import LibC

public enum SocketOptionLevel: Sendable {
    case socket, tcp, udp, ipv4, ipv6
}

extension SocketOptionLevel: RawRepresentable {
    public init?(rawValue: CInt) {
        switch rawValue {
        case SOL_SOCKET: self = .socket
        case _IPPROTO_TCP: self = .tcp
        case _IPPROTO_UDP: self = .udp
        case _IPPROTO_IP: self = .ipv4
        case _IPPROTO_IPV6: self = .ipv6
        default: return nil
        }
    }
    
    public var rawValue: CInt {
        switch self {
        case .socket: return SOL_SOCKET
        case .tcp: return _IPPROTO_TCP
        case .udp: return _IPPROTO_UDP
        case .ipv4: return _IPPROTO_IP
        case .ipv6: return _IPPROTO_IPV6
        }
    }
}
