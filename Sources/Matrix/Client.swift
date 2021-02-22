import Foundation

public class Client: ObservableObject {
    
    public var homeserver: Homeserver {
        didSet { homeserver.save() }
    }
    
    @KeychainItem(account: "uk.pixlwave.Matrix") var accessToken: String?
    
    public enum Status {
        case signedOut, syncing, idle
    }
    
    @Published public private(set) var status: Status = .signedOut
    
    @Published public private(set) var userID = ""
    
    @Published public private(set) var rooms: [Room] = []
    
    public init() {
        homeserver = Homeserver.load ?? .default
        if accessToken != nil { fullSync() }
    }
    
    private func urlComponents(path: String, queryItems: [URLQueryItem]? = nil) -> URLComponents {
        var components = homeserver.components
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
//                self.homeserver = response.homeServer
                self.accessToken = response.accessToken
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }
        .resume()
    }
    
    public func login(username: String, password: String) {
        let components = urlComponents(path: "/_matrix/client/r0/login")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = LoginUserBody(type: "m.login.password", username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else { return }
            let result = data.decode(LoginUserResponse.self)
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.userID = response.userID
//                    self.homeserver = response.homeServer
                    self.accessToken = response.accessToken
                    self.fullSync()
                }
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }
        .resume()
    }
    
    public func logout() {
        let components = urlComponents(path: "/_matrix/client/r0/logout",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else { return }
            
            DispatchQueue.main.async {
                self.accessToken = nil
                self.status = .signedOut
            }
        }
        .resume()
    }
    
    public func createRoom(name: String) {
        let components = urlComponents(path: "/_matrix/client/r0/createRoom",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = CreateRoomBody(name: name, roomAliasName: nil)
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
        }
        .resume()
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
        }
        .resume()
    }
    
    public func fullSync() {
        status = .syncing
        
        var components = urlComponents(path: "/_matrix/client/r0/sync")
        components.queryItems = [
            URLQueryItem(name: "full_state", value: "true"),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
                
        URLSession.shared.dataTask(with: components.url!) { data, response, error in
            defer { DispatchQueue.main.async { self.status = .idle } }
            guard error == nil, let data = data else { return }
            let result = data.decode(SyncResponse.self)
            
            switch result {
            case .success(let response):
                let joinedRooms = response.rooms.joined
                let rooms: [Room] = joinedRooms.keys.map { key in
                    let eventObjects = joinedRooms[key]!.timeline.events
                    let events: [Event] = eventObjects.compactMap { event in
                        guard let body = event.content["body"] else { return nil }
                        return Event(id: event.eventID, body: body, sender: event.sender)
                    }
                    return Room(id: key, events: events)
                }
                
                DispatchQueue.main.async {
                    self.rooms = rooms
                }
            case .failure(let errorResponse):
                print(errorResponse)
            }
        }
        .resume()
    }
    
    public func getLastEvent() {
        var components = urlComponents(path: "/_matrix/client/r0/sync")
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
        }
        .resume()
    }
    
}
