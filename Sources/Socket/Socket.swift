import LibC

public struct Socket: Sendable {
    public let descriptor: FileDescriptor
    
    public init(family: SocketFamily, type: SocketType = .stream) throws(Errno) {
        let result = try valueOrErrno(retryOnInterrupt: false, {
            system_socket(family.rawValue, type.rawValue, 0)
        }).get()
        
        self.init(descriptor: FileDescriptor(rawValue: result))
    }
    
    internal init(descriptor: FileDescriptor) {
        self.descriptor = descriptor
#if canImport(Darwin.C)
        self.noSignalPipe = true
#endif
        self.reuseAddr = true
    }
    
    public func blocking(_ mode: Bool) throws {
#if !canImport(ucrt)
        @discardableResult
        func fcntl(_ descriptor: FileDescriptor, _ command: CInt, _ arguments: CInt) throws -> CInt {
            try valueOrErrno(retryOnInterrupt: false, {
                system_fcntl(descriptor.rawValue, command, arguments)
            }).get()
        }
        
        var flags: CInt = try fcntl(descriptor, F_GETFL, 0)
        switch mode {
        case true: flags |= O_NONBLOCK
        case false: flags &= ~O_NONBLOCK
        }
        try fcntl(descriptor, F_SETFL, flags)
        
        //print("blocking enabled:", (try fcntl(descriptor, F_GETFL, 0) & O_NONBLOCK) != 0)
#else
        var mode: UInt32 = mode ? 0 : 1
        let result = ioctlsocket(SOCKET(descriptor.rawValue), FIONBIO, &mode)
        if result == SOCKET_ERROR {
            print(Win32Error())
        }
#endif
    }
}

public extension Socket {
    var address: SocketAddress? {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        system_getsockname(descriptor.rawValue, rebounded(&storage), &size)
        return SocketAddress(storage)
    }
    
    var peer: SocketAddress? {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        system_getpeername(descriptor.rawValue, rebounded(&storage), &size)
        return SocketAddress(storage)
    }
}

public extension Socket {
#if canImport(Darwin.C)
    var noSignalPipe: Bool {
        get { try! getOption(.noSignalPipe) }
        nonmutating set { try! setOption(.noSignalPipe, to: newValue) }
    }
#endif
    var reuseAddr: Bool {
        get { try! getOption(.reuseAddr) }
        nonmutating set { try! setOption(.reuseAddr, to: newValue) }
    }
#if !canImport(ucrt)
    var reusePort: Bool {
        get { try! getOption(.reusePort) }
        nonmutating set { try! setOption(.reusePort, to: newValue) }
    }
#endif
    var broadcast: Bool {
        get { try! getOption(.broadcast) }
        nonmutating set { try! setOption(.broadcast, to: newValue) }
    }
    
    var type: CInt {
        get { try! getOption(.type) }
        nonmutating set { try! setOption(.type, to: newValue) }
    }
}

private extension Socket {
    func getOption(_ option: SocketOption) throws(Errno) -> Bool {
        try getsockopt(descriptor, .socket, option, 0 as CInt) != 0
    }
    
    func setOption(_ option: SocketOption, to value: Bool) throws(Errno) {
        try setsockopt(descriptor, .socket, option, (value ? 1 : 0) as CInt)
    }
    
    func getOption(_ option: SocketOption) throws(Errno) -> CInt {
        try getsockopt(descriptor, .socket, option, 0 as CInt)
    }
    
    func setOption(_ option: SocketOption, to value: CInt) throws(Errno) {
        try setsockopt(descriptor, .socket, option, value)
    }
}

func setsockopt<T>(_ descriptor: FileDescriptor, _ level: SocketOptionLevel, _ option: SocketOption, _ value: T) throws(Errno) {
    let size = MemoryLayout<T>.size
    try nothingOrErrno(retryOnInterrupt: false, {
        withUnsafePointer(to: value, {
            system_setsockopt(descriptor.rawValue, level.rawValue, option.rawValue, $0, socklen_t(size))
        })
    }).get()
}

func getsockopt<T>(_ descriptor: FileDescriptor, _ level: SocketOptionLevel, _ option: SocketOption, _ value: T) throws(Errno) -> T {
    var value: T = value
    var size = socklen_t(MemoryLayout<T>.size)
    try nothingOrErrno(retryOnInterrupt: false, {
        withUnsafeMutablePointer(to: &value, {
            system_getsockopt(descriptor.rawValue, level.rawValue, option.rawValue, $0, &size)
        })
    }).get()
    return value
}

#if !canImport(ucrt)
private func system_fcntl(
    _ descriptor: CInt,
    _ command: CInt,
    _ arguments: CInt
) -> CInt {
    fcntl(descriptor, command, arguments)
}
/*
private extension FileDescriptor {
    var status: CInt {
        get { fcntl(rawValue, F_GETFL, 0) }
        nonmutating set { _ = fcntl(rawValue, F_SETFL, newValue) }
    }
}
*/
#endif
