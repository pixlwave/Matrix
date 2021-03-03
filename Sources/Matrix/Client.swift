import CoreData

public class Client: ObservableObject {
    
    public var homeserver: Homeserver {
        didSet { homeserver.save() }
    }
    
    @KeychainItem(account: "uk.pixlwave.Matrix") var accessToken: String?
    
    public enum Status { case signedOut, syncing, idle, syncError }
    
    @Published public private(set) var status: Status = .signedOut
    
    @Published public private(set) var userID = UserDefaults.standard.string(forKey: "userID") {
        didSet { UserDefaults.standard.set(userID, forKey: "userID")}
    }
    
    private var nextBatch: String?
    
    public var container: NSPersistentContainer
    lazy private var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()     // lazily created on the background thread
    
    public init() {
        guard
            let modelURL = Bundle.module.url(forResource: "Matrix", withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        else { fatalError("Unable to find Core Data Model") }
        
        container = NSPersistentContainer(name: "Matrix", managedObjectModel: managedObjectModel)
        container.loadPersistentStores { storeDescription, error in
            if let error = error { fatalError("Core Data container error: \(error)") }
        }
        
        homeserver = Homeserver.saved ?? .default
        if accessToken != nil { initialSync() }
    }
    
    private func save() {
        guard backgroundContext.hasChanges else { return }
        try? backgroundContext.save()
    }
    
    private func urlComponents(path: String, queryItems: [URLQueryItem]? = nil) -> URLComponents {
        var components = homeserver.components
        components.path = path
        components.queryItems = queryItems
        return components
    }
    
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
    
    public func register(username: String, password: String) {
        let components = urlComponents(path: "/_matrix/client/r0/register")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = RegisterUserBody(username: username, password: password, auth: ["type": "m.login.dummy"])
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        apiTask(with: request, as: RegisterUserResponse.self) { response in
            DispatchQueue.main.async {
                self.userID = response.userID
//                self.homeserver = response.homeServer
                self.accessToken = response.accessToken
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
        
        apiTask(with: request, as: LoginUserResponse.self) { response in
            DispatchQueue.main.async {
                self.userID = response.userID
//                self.homeserver = response.homeServer
                self.accessToken = response.accessToken
                self.initialSync()
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
        
        apiTask(with: request, as: CreateRoomResponse.self) { response in
            print(response)
        }
        .resume()
    }
    
    public func sendMessage(body: String, room: Room) {
        guard let roomID = room.id else { return }
        
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.room.message",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = SendMessageBody(type: "m.text", body: body)
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        apiTask(with: request, as: SendResponse.self) { response in
            print(response)
        }
        .resume()
    }
    
    public func sendReaction(text: String, to event: Message, in room: Room) {
        guard let roomID = room.id else { return }
        
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/send/m.reaction",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let bodyObject = SendReactionBody(relationship: Relationship(type: .annotation, eventID: event.id, key: text))
        request.httpBody = try? JSONEncoder().encode(bodyObject)
        
        apiTask(with: request, as: SendResponse.self) { response in
            print(response)
        }
        .resume()
    }
    
    private func getName(of room: Room) {
        guard let roomID = room.id else { return }
        
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/state/m.room.name/",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        
        apiTask(with: URLRequest(url: components.url!), as: RoomNameResponse.self) { response in
            room.objectWillChange.send()
            room.name = response.name
            self.save()
        } onFailure: { errorResponse in
            print(errorResponse)
            room.objectWillChange.send()
            room.name = room.members.filter { $0.id != self.userID }.compactMap { $0.displayName ?? $0.id }.joined(separator: ", ")
            self.save()
        }
        .resume()
    }
    
    private func getMembers(in room: Room) {
        guard let roomID = room.id else { return }
        
        let components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/members",
                                       queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        
        apiTask(with: URLRequest(url: components.url!), as: Members.self) { response in
            let members = response.members.filter { $0.type == "m.room.member" && $0.content.membership == .join }
                                          .map { Member(event: $0, context: self.backgroundContext) }
            
            room.roomMembers = NSSet(array: members)
            self.save()
        }
        .resume()
    }
    
    private let initialSyncFilter = """
    {"room":{"state":{"lazy_load_members":true},"timeline":{"limit":1}}}
    """
    
    public func initialSync() {
        status = .syncing
        
        var components = urlComponents(path: "/_matrix/client/r0/sync")
        components.queryItems = [
            URLQueryItem(name: "filter", value: initialSyncFilter),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        apiTask(with: URLRequest(url: components.url!), as: SyncResponse.self) { response in
            let joinedRooms = response.rooms.joined
            let rooms: [Room] = joinedRooms.keys.map { key in
                Room(id: key, joinedRoom: joinedRooms[key]!, context: self.backgroundContext)
            }
            
            self.save()
            
            DispatchQueue.main.async {
                self.status = .idle
                self.nextBatch = response.nextBatch
                self.longPoll()
                
                rooms.forEach {
                    self.getName(of: $0)
                    self.getMembers(in: $0)
                    self.loadMoreMessages(in: $0)
                }
            }
        } onFailure: { errorResponse in
            print(errorResponse)
            DispatchQueue.main.async {
                self.status = .syncError
            }
        }
        .resume()
    }
    
    public func longPoll() {
        var components = urlComponents(path: "/_matrix/client/r0/sync")
        components.queryItems = [
            URLQueryItem(name: "since", value: nextBatch),
            URLQueryItem(name: "timeout", value: "5000"),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        apiTask(with: URLRequest(url: components.url!), as: SyncResponse.self) { response in
            let joinedRooms = response.rooms.joined
            joinedRooms.keys.forEach { key in
                Room(id: key, joinedRoom: joinedRooms[key]!, context: self.backgroundContext)
            }
            
            self.save()
            
//            rooms.forEach { room in
//                if let index = self.rooms.firstIndex(where: { room.id == $0.id }) {
//                    self.rooms[index].events.append(contentsOf: room.events)
//                } else {
//                    self.rooms.append(room)
//                    self.getName(of: room)
//                }
//            }
            
            self.nextBatch = response.nextBatch
            self.longPoll()
        }
        .resume()
    }
    
    public func loadMoreMessages(in room: Room) {
        guard let roomID = room.id else { return }
        
        var components = urlComponents(path: "/_matrix/client/r0/rooms/\(roomID)/messages")
        components.queryItems = [
            URLQueryItem(name: "from", value: room.previousBatch),
            URLQueryItem(name: "dir", value: "b"),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        apiTask(with: URLRequest(url: components.url!), as: MessagesResponse.self) { response in
            let messages = response.events?.filter { $0.type == "m.room.message" }
                                           .compactMap { Message(roomEvent: $0, context: self.backgroundContext) }
            
            if let messages = messages {
                room.addToRoomMessages(NSSet(array: messages))
            }
            
            room.previousBatch = response.endToken
            
            self.save()
        }
        .resume()
    }
}
