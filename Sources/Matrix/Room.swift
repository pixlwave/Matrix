import Foundation

public class Room: ObservableObject, Identifiable {
    public let id: String
    @Published public var name: String?
    @Published public var events: [Event]
    
    @Published public var members: [Member]
    
    init(id: String, name: String? = nil, events: [Event], members: [Member]) {
        self.id = id
        self.name = name
        self.events = events
        self.members = members
    }
    
    init(id: String, joinedRoom: JoinedRooms, currentUserID: String) {
        let events = joinedRoom.timeline.events.compactMap { Event(roomEvent: $0, currentUserID: currentUserID) }
        let members = joinedRoom.state.events.filter { $0.type == "m.room.member" && $0.content.membership == .join }
                                             .map { Member(event: $0) }
        
        self.id = id
        self.events = events
        self.members = members
    }
}
