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
        if components.host == nil { components.host = "matrix.org" }
        if components.port == nil { components.port = components.scheme == "https" ? 8448 : 8008 }
        
        self.components = components
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "homeserver")
    }
    
    static var saved: Homeserver? {
        guard let data = UserDefaults.standard.data(forKey: "homeserver") else { return nil }
        return try? JSONDecoder().decode(Homeserver.self, from: data)
    }
    
    static var `default`: Homeserver{
        Homeserver(scheme: "https", host: "matrix.org", port: 8448)
    }
}
