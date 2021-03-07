import Foundation

public struct RoomEvent: Codable {
    public let content: RoomEventContent
    public let type: String
    public let eventID: String
    public let sender: String
    public let timestamp: TimeInterval
//    public let unsigned: UnsignedData
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case timestamp = "origin_server_ts"
    }
    
    public struct RoomEventContent: Codable {
        public let body: String?
        public let relationship: Relationship?
        public let newContent: NewContent?
        
        enum CodingKeys: String, CodingKey {
            case body
            case relationship = "m.relates_to"
            case newContent = "m.new_content"
        }
        
        public struct NewContent: Codable {
            public let body: String?
        }
    }
}
