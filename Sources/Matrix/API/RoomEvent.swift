import Foundation

public struct RoomEvent: Codable {
    public let content: RoomEventContent
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
//    public let unsigned: UnsignedData
    
    // m.room.redaction
    public let redacts: String?
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case redacts
    }
    
    public struct RoomEventContent: Codable {
        public let body: String?
        public let relationship: Relationship?
        
        // edit event
        public let newContent: NewContent?
        
        // m.room.redaction
        public let reason: String?
        
        enum CodingKeys: String, CodingKey {
            case body
            case relationship = "m.relates_to"
            case newContent = "m.new_content"
            case reason
        }
        
        public struct NewContent: Codable {
            public let body: String?
        }
    }
}
