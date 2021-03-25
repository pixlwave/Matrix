import Foundation
import Combine

public class Client {
    
    public var homeserver: Homeserver = .default
    
    public var accessToken: String?
    
    public init() { }
    
    private func urlComponents(path: String) -> URLComponents {
        var components = homeserver.components
        components.path = path
        components.queryItems = []
        return components
    }
    
    private func urlRequest(url: URL, withAuthorization: Bool) -> URLRequest {
        var request = URLRequest(url: url)
        
        if withAuthorization, let accessToken = accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func apiPublisher<T: Decodable>(with request: URLRequest, as type: T.Type) -> AnyPublisher<T, MatrixError> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { try $0.data.decode(type) }
            .mapError { error in
                if let error = error as? URLError {
                    return .urlError(error: error)
                } else if let error = error as? DecodingError {
                    return .decodeError(error: error)
                } else if let error = error as? ErrorResponse {
                    return .errorResponse(error: error)
                } else {
                    return .unknown(error: error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // 5.5.2 POST /_matrix/client/r0/login
    public func login(username: String, password: String) -> AnyPublisher<LoginUserResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/login")
        var request = urlRequest(url: components.url!, withAuthorization: false)
        request.httpMethod = "POST"
        let bodyObject = LoginUserBody(type: "m.login.password", username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: LoginUserResponse.self)
    }
    
    // 5.5.3 POST /_matrix/client/r0/logout
    public func logout() -> AnyPublisher<Bool, URLError> {
        let components = urlComponents(path: "/_matrix/client/r0/logout")
        var request = urlRequest(url: components.url!, withAuthorization: true)
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .map { $0?.statusCode == 200 }
            .eraseToAnyPublisher()
    }
    
    // 5.6.1 POST /_matrix/client/r0/register
    public func register(username: String, password: String) -> AnyPublisher<RegisterUserResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/register")
        var request = urlRequest(url: components.url!, withAuthorization: false)
        request.httpMethod = "POST"
        let bodyObject = RegisterUserBody(username: username, password: password, auth: ["type": "m.login.dummy"])
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: RegisterUserResponse.self)
    }
    
    private let initialSyncFilter = """
    {"room":{"state":{"lazy_load_members":true},"timeline":{"limit":1}}}
    """
    
    // 9.4.1 GET /_matrix/client/r0/sync
    public func sync(since: String? = nil, timeout: Int? = nil) -> AnyPublisher<SyncResponse, MatrixError> {
        var components = urlComponents(path: "/_matrix/client/r0/sync")
        
        if let since = since {
            components.queryItems?.append(URLQueryItem(name: "since", value: since))
        } else {
            components.queryItems?.append(URLQueryItem(name: "filter", value: initialSyncFilter))
        }
        
        if let timeout = timeout {
            components.queryItems?.append(URLQueryItem(name: "timeout", value: String(timeout)))
        }
        
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: SyncResponse.self)
    }
    
    // 9.5.2 GET /_matrix/client/r0/rooms/{roomId}/state/{eventType}/{stateKey}
    public func getName(of roomID: String) -> AnyPublisher<RoomNameResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/state/m.room.name/")
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: RoomNameResponse.self)
    }
    
    // 9.5.4 GET /_matrix/client/r0/rooms/{roomId}/members
    public func getMembers(of roomID: String) -> AnyPublisher<MembersResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/members")
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: MembersResponse.self)
    }
    
    // 9.5.6 GET /_matrix/client/r0/rooms/{roomId}/messages
    public func loadMessages(in roomID: String, from paginationToken: String, count messageCount: UInt = 10) -> AnyPublisher<MessagesResponse, MatrixError> {
        var components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/messages")
        components.queryItems = [
            URLQueryItem(name: "from", value: paginationToken),
            URLQueryItem(name: "dir", value: "b"),
            URLQueryItem(name: "limit", value: String(messageCount))
        ]
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: MessagesResponse.self)
    }
    
    // 9.6.2 PUT /_matrix/client/r0/rooms/{roomId}/send/{eventType}/{txnId}
    public func sendMessage(body: String, roomID: String) -> AnyPublisher<SendResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.room.message")
        var request = urlRequest(url: components.url!, withAuthorization: true)
        request.httpMethod = "POST"
        let bodyObject = SendMessageBody(type: "m.text", body: body)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: SendResponse.self)
    }
    
    // 9.6.2 PUT /_matrix/client/r0/rooms/{roomId}/send/{eventType}/{txnId}
    public func sendReaction(text: String, to eventID: String, in roomID: String) -> AnyPublisher<SendResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.reaction")
        var request = urlRequest(url: components.url!, withAuthorization: true)
        request.httpMethod = "POST"
        let bodyObject = SendReactionBody(relationship: Relationship(type: .annotation, eventID: eventID, key: text))
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: SendResponse.self)
    }
    
    // 10.1.1 POST /_matrix/client/r0/createRoom
    public func createRoom(name: String) -> AnyPublisher<CreateRoomResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/createRoom")
        var request = urlRequest(url: components.url!, withAuthorization: true)
        request.httpMethod = "POST"
        let bodyObject = CreateRoomBody(name: name, roomAliasName: nil)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: CreateRoomResponse.self)
    }
}
