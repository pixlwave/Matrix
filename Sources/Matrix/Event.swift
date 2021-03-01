import Foundation

public struct Event: Identifiable, Equatable {
    public let id: String
    public let body: String
    public let sender: String
    public let isMe: Bool
    
    init(id: String, body: String, sender: String, isMe: Bool) {
        self.id = id
        self.body = body
        self.sender = sender
        self.isMe = isMe
    }
    
    init?(roomEvent: RoomEvent, currentUserID: String) {
        guard let body = roomEvent.content.body else { return nil }
        
        self.id = roomEvent.eventID
        self.body = body
        self.sender = roomEvent.sender
        self.isMe = roomEvent.sender == currentUserID
    }
}
