import Foundation
import Combine

public class Client {
    
    public var homeserver: Homeserver = .default
    
    public var accessToken: String?
    
    #warning("Is this the best place to set these?")
    public static var eventTypes: [RoomEvent.Type] = [
        RoomMessageEvent.self, RoomReactionEvent.self, RoomRedactionEvent.self,
        RoomMemberEvent.self, RoomNameEvent.self, RoomEncryptionEvent.self
    ]
    
    public init() { }
    
    private func urlComponents(path: String) -> URLComponents {
        var components = homeserver.components
        components.path = path
        components.queryItems = []
        return components
    }
    
    private func urlRequest(url: URL, withAuthorization: Bool) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if withAuthorization, let accessToken {
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
    
    // 4.1.1 GET /.well-known/matrix/client
    public func lookupHomeserver(for host: String) -> AnyPublisher<WellKnownResponse, Error> {
        var components = URLComponents()
        components.host = host
        components.scheme = "https"
        components.path = "/.well-known/matrix/client"
        
        guard let url = components.url else {
            let error = ErrorResponse(code: "FAIL_PROMPT", message: "Auto-discovery failed due to invalid/empty data.")
            return Fail<WellKnownResponse, Error>(error: error).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: WellKnownResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // 5.5.2 POST /_matrix/client/r0/login
    public func login(username: String, password: String, displayName: String? = nil) -> AnyPublisher<LoginUserResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/login")
        
        var request = urlRequest(url: components.url!, withAuthorization: false)
        request.httpMethod = "POST"
        
        let body = LoginUserBody(type: "m.login.password", identifier: .user(username), password: password, displayName: displayName)
        request.httpBody = try? JSONEncoder().encode(body)
        
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
    public func register(username: String, password: String, displayName: String? = nil) -> AnyPublisher<RegisterUserResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/register")
        
        var request = urlRequest(url: components.url!, withAuthorization: false)
        request.httpMethod = "POST"
        
        let body = RegisterUserBody(username: username, password: password, auth: ["type": "m.login.dummy"], displayName: displayName)
        request.httpBody = try? JSONEncoder().encode(body)
        
        return apiPublisher(with: request, as: RegisterUserResponse.self)
    }
    
    // 9.4.1 GET /_matrix/client/r0/sync
    public func sync(filter: String? = nil, since: String? = nil, timeout: Int? = nil) -> AnyPublisher<SyncResponse, MatrixError> {
        var components = urlComponents(path: "/_matrix/client/r0/sync")
        var queryItems = [URLQueryItem]()
        
        if let filter = filter {
            queryItems.append(URLQueryItem(name: "filter", value: filter))
        }
        
        if let since = since {
            queryItems.append(URLQueryItem(name: "since", value: since))
        }
        
        if let timeout = timeout {
            queryItems.append(URLQueryItem(name: "timeout", value: String(timeout)))
        }
        
        components.queryItems = queryItems
        
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: SyncResponse.self)
    }
    
    // 9.5.2 GET /_matrix/client/r0/rooms/{roomId}/state/{eventType}/{stateKey}
    public func getCreateEvent(for roomID: String) -> AnyPublisher<RoomCreateEvent.Content, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/state/m.room.create/")
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: RoomCreateEvent.Content.self)
    }
    
    // 9.5.2 GET /_matrix/client/r0/rooms/{roomId}/state/{eventType}/{stateKey}
    public func getName(of roomID: String) -> AnyPublisher<RoomNameEvent.Content, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/state/m.room.name/")
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: RoomNameEvent.Content.self)
    }
    
    // 9.5.4 GET /_matrix/client/r0/rooms/{roomId}/members
    public func getMembers(of roomID: String, at paginationToken: String? = nil) -> AnyPublisher<MembersResponse, MatrixError> {
        var components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/members")
        
        if let paginationToken = paginationToken {
            components.queryItems?.append(URLQueryItem(name: "at", value: paginationToken))
        }
        
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: MembersResponse.self)
    }
    
    // 9.5.6 GET /_matrix/client/r0/rooms/{roomId}/messages
    public func getMessages(in roomID: String, from paginationToken: String, limit: Int = 10) -> AnyPublisher<MessagesResponse, MatrixError> {
        var components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/messages")
        components.queryItems = [
            URLQueryItem(name: "from", value: paginationToken),
            URLQueryItem(name: "dir", value: "b"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        let request = urlRequest(url: components.url!, withAuthorization: true)
        
        return apiPublisher(with: request, as: MessagesResponse.self)
    }
    
    // 9.6.2 PUT /_matrix/client/r0/rooms/{roomId}/send/{eventType}/{txnId}
    public func send<Content: Encodable>(_ content: Content, as eventType: RoomEvent.Type, in roomID: String, with transactionID: String) -> AnyPublisher<SendResponse, MatrixError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/\(eventType.type)/\(transactionID)")
        
        var request = urlRequest(url: components.url!, withAuthorization: true)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(content)
        
        return apiPublisher(with: request, as: SendResponse.self)
    }
    
    // 9.6.2 convenience method for m.room.message
    public func sendMessage(_ message: String, in roomID: String, with transactionID: String) -> AnyPublisher<SendResponse, MatrixError> {
        let content = MessageContent(body: message, type: .text)
        return send(content, as: RoomMessageEvent.self, in: roomID, with: transactionID)
    }
    
    // 9.6.2 convenience method for m.redaction
    public func sendReaction(_ reaction: String, to eventID: String, in roomID: String, with transactionID: String) -> AnyPublisher<SendResponse, MatrixError> {
        let content = RoomReactionEvent.Content(relationship: Relationship(type: .annotation, eventID: eventID, key: reaction))
        return send(content, as: RoomReactionEvent.self, in: roomID, with: transactionID)
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
    
    // 13.5.2.1 POST /_matrix/client/r0/rooms/{roomId}/receipt/{receiptType}/{eventId}
    public func sendReadReceipt(for eventID: String, in roomID: String) -> AnyPublisher<Bool, URLError> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/receipt/m.read/\(eventID)")
        var request = urlRequest(url: components.url!, withAuthorization: true)
        request.httpMethod = "POST"
        request.httpBody = "{}".data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.response as? HTTPURLResponse }
            .map { $0?.statusCode == 200 }
            .eraseToAnyPublisher()
    }
    
    // Authenticated URL request for path /_matrix/client/v1/media/download/{serverName}/{mediaId}
    public func mediaDownloadURLRequest(fromMXC url: URL) -> URLRequest {
        guard
            url.scheme == "mxc",
            let host = url.host,
            let mediaID = url.pathComponents.last   // pathComponents are ["/", "mediaID"]
        else { return URLRequest(url: url) }
        
        let components = urlComponents(path: "/_matrix/client/v1/media/download/\(host)/\(mediaID)")
        
        return urlRequest(url: components.url!, withAuthorization: true)
    }
    
    // GET /_matrix/client/v1/media/download/{serverName}/{mediaId}
    public func downloadMedia(at url: URL) -> AnyPublisher<Data, URLError> {
        let request = mediaDownloadURLRequest(fromMXC: url)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
