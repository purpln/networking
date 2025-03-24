import LibC

@_alwaysEmitIntoClient
internal var _IPPROTO_TCP: CInt {
#if !os(Windows)
    CInt(IPPROTO_TCP)
#else
    IPPROTO_TCP.rawValue
#endif
}

@_alwaysEmitIntoClient
internal var _IPPROTO_UDP: CInt {
#if !os(Windows)
    CInt(IPPROTO_UDP)
#else
    IPPROTO_UDP.rawValue
#endif
}

@_alwaysEmitIntoClient
internal var _IPPROTO_RAW: CInt {
#if !os(Windows)
    CInt(IPPROTO_RAW)
#else
    IPPROTO_RAW.rawValue
#endif
}

@_alwaysEmitIntoClient
internal var _IPPROTO_IP: CInt {
    CInt(IPPROTO_IP)
}

@_alwaysEmitIntoClient
internal var _IPPROTO_IPV6: CInt {
#if !os(Windows)
    CInt(IPPROTO_IPV6)
#else
    IPPROTO_IPV6.rawValue
#endif
}
