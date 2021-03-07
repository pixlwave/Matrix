import Foundation
import Combine

public class Client {
    
    public var homeserver: Homeserver = Homeserver.saved ?? .default {
        didSet { homeserver.save() }
    }
    
    @KeychainItem(account: "uk.pixlwave.Matrix") var accessToken: String?
    
    private func urlComponents(path: String, queryItems: [URLQueryItem]? = nil) -> URLComponents {
        var components = homeserver.components
        components.path = path
        components.queryItems = queryItems
        return components
    }
    
    #warning("Remove me.")
    private func apiTask<T>(with request: URLRequest,
                            as type: T.Type,
                            onSuccess: @escaping (T) -> (),
                            onFailure: ((ErrorResponse) -> ())? = nil) -> URLSessionDataTask where T: Decodable {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                onFailure?(ErrorResponse(code: "URLSession Error", message: error.localizedDescription))
                return
            }
            
            guard let data = data else {
                print("Missing Response Data")
                onFailure?(ErrorResponse(code: "Missing Response Data", message: "Empty response"))
                return
            }
            let result = data.decode(T.self)
            
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let errorResponse):
                print(errorResponse)
                onFailure?(errorResponse)
            }
        }
    }
    
    private func apiPublisher<T: Decodable>(with request: URLRequest, as type: T.Type) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: type, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func register(username: String, password: String) -> AnyPublisher<RegisterUserResponse, Error> {
        let components = urlComponents(path: "/_matrix/client/r0/register")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = RegisterUserBody(username: username, password: password, auth: ["type": "m.login.dummy"])
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: RegisterUserResponse.self)
    }
    
    func login(username: String, password: String) -> AnyPublisher<LoginUserResponse, Error> {
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
    
    func createRoom(name: String) -> AnyPublisher<CreateRoomResponse, Error> {
        let components = urlComponents(path: "/_matrix/client/r0/createRoom",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = CreateRoomBody(name: name, roomAliasName: nil)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: CreateRoomResponse.self)
    }
    
    func sendMessage(body: String, roomID: String) -> AnyPublisher<SendResponse, Error> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.room.message",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = SendMessageBody(type: "m.text", body: body)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: SendResponse.self)
    }
    
    func sendReaction(text: String, to eventID: String, in roomID: String) -> AnyPublisher<SendResponse, Error> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.reaction",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = SendReactionBody(relationship: Relationship(type: .annotation, eventID: eventID, key: text))
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        return apiPublisher(with: request, as: SendResponse.self)
    }
    
    func getName(of roomID: String) -> AnyPublisher<RoomNameResponse, Error> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/state/m.room.name/",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        let request = URLRequest(url: components.url!)
        
        return apiPublisher(with: request, as: RoomNameResponse.self)
    }
    
    func getMembers(in roomID: String) -> AnyPublisher<Members, Error> {
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/members",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        let request = URLRequest(url: components.url!)
        
        return apiPublisher(with: request, as: Members.self)
    }
    
    private let initialSyncFilter = """
    {"room":{"state":{"lazy_load_members":true},"timeline":{"limit":1}}}
    """
    
    func sync(since: String? = nil, timeout: Int? = nil) -> AnyPublisher<SyncResponse, Error> {
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
    
    func loadMessages(in roomID: String, from paginationToken: String) -> AnyPublisher<MessagesResponse, Error> {
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
