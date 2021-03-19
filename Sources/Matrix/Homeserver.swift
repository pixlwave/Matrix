import Foundation

public struct Homeserver: Codable {
    let components: URLComponents
    public var address: String? { components.url?.absoluteString }
    
    init(scheme: String, host: String, port: Int) {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        self.components = components
    }
    
    public init?(string: String) {
        guard
            let url = URL(string: string),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return nil }
        
        if components.scheme == nil { components.scheme = "https" }
        if components.host == nil { components.host = "matrix-federation.matrix.org" }
        if components.port == nil { components.port = components.scheme == "https" ? 443 : 8008 }
        
        self.components = components
    }
    
    public init?(data: Data) {
        guard let decoded = try? JSONDecoder().decode(Homeserver.self, from: data) else { return nil }
        self = decoded
    }
    
    public func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
    
    public static var `default`: Homeserver {
        Homeserver(scheme: "https", host: "matrix-federation.matrix.org", port: 443)
    }
}
