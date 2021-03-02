import Foundation

public class Event: Identifiable, Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: String
    public let sender: String
    public let date: Date
    
    init(id: String, sender: String, date: Date, isMe: Bool) {
        self.id = id
        self.sender = sender
        self.date = date
    }
    
    init?(roomEvent: RoomEvent) {
        self.id = roomEvent.eventID
        self.sender = roomEvent.sender
        self.date = Date(timeIntervalSince1970: roomEvent.timestamp / 1000)
    }
}


public class MessageEvent: Event {
    public let body: String
    public let reactions: [ReactionEvent] = []
    
    init(id: String, body: String, sender: String, date: Date, isMe: Bool) {
        self.body = body
        super.init(id: id, sender: sender, date: date, isMe: isMe)
    }
    
    override init?(roomEvent: RoomEvent) {
        guard let body = roomEvent.content.body else { return nil }
        
        self.body = body
        super.init(roomEvent: roomEvent)
    }
}


public class ReactionEvent: Event {
    public let key: String
    public let relatedToEventID: String
    
    override init?(roomEvent: RoomEvent) {
        guard
            let key = roomEvent.content.relationship?.key,
            let relatedToEventID = roomEvent.content.relationship?.eventID
        else { return nil }
        
        self.key = key
        self.relatedToEventID = relatedToEventID
        super.init(roomEvent: roomEvent)
    }
}
