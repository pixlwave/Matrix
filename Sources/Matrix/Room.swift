import Foundation

public class Room: ObservableObject, Identifiable {
    public let id: String
    @Published public var name: String?
    @Published public var events: [Event]
    @Published var previousBatch: String?
    
    @Published public var members: [Member]
    
    public var hasMoreMessages: Bool { previousBatch != nil }
    
    init(id: String, name: String? = nil, events: [Event], members: [Member]) {
        self.id = id
        self.name = name
        self.events = events
        self.members = members
    }
    
    init(id: String, joinedRoom: JoinedRooms, currentUserID: String) {
        let events = joinedRoom.timeline.events.compactMap { $0.makeEvent() }
        let members = joinedRoom.state.events.filter { $0.type == "m.room.member" && $0.content.membership == .join }
                                             .map { Member(event: $0) }
        
        self.id = id
        self.events = events
        self.members = members
        self.previousBatch = joinedRoom.timeline.previousBatch
    }
    
    public func lastMessage() -> MessageEvent? {
        events.compactMap { $0 as? MessageEvent }.last
    }
}
