import Foundation

public struct Event: Identifiable, Equatable {
    public let id: String
    public let body: String
    public let sender: String
    public let date: Date
    public let isMe: Bool
    
    init(id: String, body: String, sender: String, date: Date, isMe: Bool) {
        self.id = id
        self.body = body
        self.sender = sender
        self.date = date
        self.isMe = isMe
    }
    
    init?(roomEvent: RoomEvent, currentUserID: String) {
        guard let body = roomEvent.content.body else { return nil }
        
        self.id = roomEvent.eventID
        self.body = body
        self.sender = roomEvent.sender
        self.date = Date(timeIntervalSince1970: roomEvent.timestamp / 1000)
        self.isMe = roomEvent.sender == currentUserID
    }
}
