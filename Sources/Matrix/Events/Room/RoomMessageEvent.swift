import Foundation

public struct RoomMessageEvent: RoomEvent {
    public static var type = "m.room.message"
    
    public let content: Content
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
    public let unsigned: UnsignedData?
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
    }
    
    public struct Content: Decodable {
        // required
        public let body: String?
        public let type: MessageType?
        
        // optional
        public let relationship: Relationship?
        public let url: URL?
        
        // edit event
        public let newContent: NewContent?
        
        enum CodingKeys: String, CodingKey {
            case body
            case type = "msgtype"
            case relationship = "m.relates_to"
            case url
            case newContent = "m.new_content"
        }
        
        public struct NewContent: Decodable {
            public let body: String?
        }
        
        public enum MessageType: String, Decodable {
            case text = "m.text"
            case emote = "m.emote"
            case notice = "m.notice"
            case image = "m.image"
            case file = "m.file"
            case audio = "m.audio"
            case location = "m.location"
            case video = "m.video"
            case unknown
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self = MessageType(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
            }
        }
    }
}
