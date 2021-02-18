import Foundation

public class Client: ObservableObject {
    
    let host: String
    let port: Int
    var accessToken: String?
    
    @Published public private(set) var userID = ""
    @Published public private(set) var homeserver = ""
    
    @Published public private(set) var rooms: [Room] = []
    
    public init(host: String, port: Int, accessToken: String? = nil) {
        self.host = host
        self.port = port
        self.accessToken = accessToken
    }
    
    private func urlComponents(path: String = "", queryItems: [URLQueryItem]? = nil) -> URLComponents {
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = queryItems
        return components
    }
    
    public func register(username: String, password: String) {
        let components = urlComponents(path: "/_matrix/client/r0/register")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = RegisterUserBody(username: username, password: password, auth: ["type": "m.login.dummy"])
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else { return }
            let result = data.decode(RegisterUserResponse.self)
            
            switch result {
            case .success(let response):
                self.userID = response.userID
                self.homeserver = response.homeServer
                self.accessToken = response.accessToken
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }.resume()
    }
    
    public func login(username: String, password: String) {
        let components = urlComponents(path: "/_matrix/client/r0/login")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        let bodyObject = LoginUserBody(type: "m.login.password", username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else { return }
            let result = data.decode(LoginUserResponse.self)
            
            switch result {
            case .success(let response):
                self.userID = response.userID
                self.homeserver = response.homeServer
                self.accessToken = response.accessToken
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }.resume()
    }
    
    public func createRoom(name: String) {
        let components = urlComponents(path: "/_matrix/client/r0/createRoom",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = CreateRoomBody(roomAliasName: "Tutorial")
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else { return }
            let result = data.decode(CreateRoomResponse.self)
            
            switch result {
            case .success(let response):
                print(response)
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }.resume()
    }
    
    public func sendMessage(body: String, roomID: String) {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.room.message",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = SendMessageBody(type: "m.text", body: body)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let data = data else { print(response.debugDescription); return }
            let result = data.decode(SendMessageResponse.self)
            
            switch result {
            case .success(let response):
                print(response)
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }.resume()
    }
    
    public func fullSync() {
        var components = urlComponents()
        components.path = "/_matrix/client/r0/sync"
        components.queryItems = [
            URLQueryItem(name: "full_state", value: "true"),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
                
        URLSession.shared.dataTask(with: components.url!) { data, response, error in
            guard error == nil, let data = data else { return }
            let result = data.decode(SyncResponse.self)
            
            switch result {
            case .success(let response):
                let joinedRooms = response.rooms.joined
                let rooms: [Room] = joinedRooms.keys.map { key in
                    let eventObjects = joinedRooms[key]!.timeline.events
                    let events = eventObjects.map { Event(id: $0.eventID, body: $0.content["body"] ?? "Unknown Event", sender: $0.sender) }
                    return Room(id: key, events: events)
                }
                
                DispatchQueue.main.async {
                    self.rooms = rooms
                }
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }.resume()
    }
    
    public func getLastEvent() {
        var components = urlComponents()
        components.path = "/_matrix/client/r0/sync"
        components.queryItems = [
            URLQueryItem(name: "filter", value: "{\"room\":{\"timeline\":{\"limit\":1}}}"),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
                
        URLSession.shared.dataTask(with: components.url!) { data, response, error in
            guard error == nil, let data = data else { return }
            let result = data.decode(SyncResponse.self)
            
            switch result {
            case .success(let response):
                print(response)
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }.resume()
    }
    
}
