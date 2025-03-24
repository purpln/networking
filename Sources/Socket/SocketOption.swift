import LibC

public enum SocketOption: Sendable {
    case reuseAddr
#if !canImport(ucrt)
    case reusePort
    case timestamp
#endif
    case broadcast
#if canImport(Darwin.C)
    case noSignalPipe
#endif
    case sendBufferSize
    case receiveBufferSize
    case sendTimeout
    case receiveTimeout
    case error
    case type
}

extension SocketOption {
    var rawValue: CInt {
        switch self {
        case .reuseAddr: return SO_REUSEADDR
#if !canImport(ucrt)
        case .reusePort: return SO_REUSEPORT
        case .timestamp: return SO_TIMESTAMP
#endif
        case .broadcast: return SO_BROADCAST
#if canImport(Darwin.C)
        case .noSignalPipe: return SO_NOSIGPIPE
#endif
        case .sendBufferSize: return SO_SNDBUF
        case .receiveBufferSize: return SO_RCVBUF
        case .sendTimeout: return SO_SNDTIMEO
        case .receiveTimeout: return SO_RCVTIMEO
        case .error: return SO_ERROR
        case .type: return SO_TYPE
        }
    }
}

