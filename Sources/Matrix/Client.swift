import Foundation
import Combine

public class Client {
    
    public var homeserver: Homeserver = Homeserver.saved ?? .default {
        didSet { homeserver.save() }
    }
    
    @KeychainItem(account: "uk.pixlwave.Matrix") public var accessToken: String?
    
    public init() { }
    
    private func urlComponents(path: String, queryItems: [URLQueryItem]? = nil) -> URLComponents {
        var components = homeserver.components
        components.path = path
        components.queryItems = queryItems
        return components
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
    
    public func register(username: String, password: String) -> AnyPublisher<RegisterUserResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/register")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = RegisterUserBody(username: username, password: password, auth: ["type": "m.login.dummy"])
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: RegisterUserResponse.self)
    }
    
    public func login(username: String, password: String) -> AnyPublisher<LoginUserResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/login")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = LoginUserBody(type: "m.login.password", username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: LoginUserResponse.self)
    }
    
    public func logout() -> AnyPublisher<Bool, URLError> {
        let components = urlComponents(path: "/_matrix/client/r0/logout",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .map { $0?.statusCode == 200 }
            .eraseToAnyPublisher()
    }
    
    public func createRoom(name: String) -> AnyPublisher<CreateRoomResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/createRoom",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = CreateRoomBody(name: name, roomAliasName: nil)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: CreateRoomResponse.self)
    }
    
    public func sendMessage(body: String, roomID: String) -> AnyPublisher<SendResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.room.message",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = SendMessageBody(type: "m.text", body: body)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: SendResponse.self)
    }
    
    public func sendReaction(text: String, to eventID: String, in roomID: String) -> AnyPublisher<SendResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.reaction",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = SendReactionBody(relationship: Relationship(type: .annotation, eventID: eventID, key: text))
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: SendResponse.self)
    }
    
    public func getName(of roomID: String) -> AnyPublisher<RoomNameResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/state/m.room.name/",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        let request = URLRequest(url: components.url!)
        
        return apiPublisher(with: request, as: RoomNameResponse.self)
    }
    
    public func getMembers(in roomID: String) -> AnyPublisher<MembersResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/members",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        let request = URLRequest(url: components.url!)
        
        return apiPublisher(with: request, as: MembersResponse.self)
    }
    
    private let initialSyncFilter = """
    {"room":{"state":{"lazy_load_members":true},"timeline":{"limit":1}}}
    """
    
    public func sync(since: String? = nil, timeout: Int? = nil) -> AnyPublisher<SyncResponse, MatrixError> {
        var components = urlComponents(path: "/_matrix/client/r0/sync",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        
        if let since = since {
            components.queryItems?.append(URLQueryItem(name: "since", value: since))
        } else {
            components.queryItems?.append(URLQueryItem(name: "filter", value: initialSyncFilter))
        }
        
        if let timeout = timeout {
            components.queryItems?.append(URLQueryItem(name: "timeout", value: String(timeout)))
        }
        
        let request = URLRequest(url: components.url!)
        
        return apiPublisher(with: request, as: SyncResponse.self)
    }
    
    public func loadMessages(in roomID: String, from paginationToken: String) -> AnyPublisher<MessagesResponse, MatrixError> {
        var components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/messages")
        components.queryItems = [
            URLQueryItem(name: "from", value: paginationToken),
            URLQueryItem(name: "dir", value: "b"),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        let request = URLRequest(url: components.url!)
        
        return apiPublisher(with: request, as: MessagesResponse.self)
    }
}
