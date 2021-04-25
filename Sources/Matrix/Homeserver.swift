import Foundation

public struct Homeserver: Codable {
    let components: URLComponents
    
    public var description: String? {
        components.host
    }
    
    init(scheme: String, host: String, port: Int) {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        self.components = components
    }
    
    #warning("If no scheme or port is included in the string, URLComponents is assigning the hostname to the path")
    public init?(string: String) {
        guard
            let url = URL(string: string),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.host != nil
        else { return nil }
        
        if components.scheme == nil { components.scheme = "https" }
        if components.port == nil && components.scheme == "http" { components.port = 8008 }
        
        self.components = components
    }
    
    public init?(url: URL) {
        guard
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.host != nil
        else { return nil }
        
        if components.scheme == nil { components.scheme = "https" }
        if components.port == nil && components.scheme == "http" { components.port = 8008 }
        
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
        Homeserver(scheme: "https", host: "matrix-client.matrix.org", port: 443)
    }
}
