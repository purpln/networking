import LibC

enum SocketCommunicationProtocol: Sendable {
    case raw, tcp, udp
}

extension SocketCommunicationProtocol: RawRepresentable {
    public init?(rawValue: CInt) {
        switch rawValue {
        case _IPPROTO_TCP: self = .tcp
        case _IPPROTO_UDP: self = .udp
        case _IPPROTO_RAW: self = .raw
        default: return nil
        }
    }
    
    public var rawValue: CInt {
        switch self {
        case .tcp: return _IPPROTO_TCP
        case .udp: return _IPPROTO_UDP
        case .raw: return _IPPROTO_RAW
        }
    }
}
