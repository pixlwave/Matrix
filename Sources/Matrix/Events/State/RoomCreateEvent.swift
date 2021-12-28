import Foundation

public struct RoomCreateEvent: RoomEvent {
    public static let type = "m.room.create"
    
    public let content: Content
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
    public let unsigned: UnsignedData?
    
    public let stateKey: String?
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
        case stateKey = "state_key"
    }
    
    public struct Content: Decodable {
        public let creatorID: String
        public let canFederate: Bool?
        public let roomVersion: String?
        
        public let type: RoomType?
        
        enum CodingKeys: String, CodingKey {
            case creatorID = "creator"
            case canFederate = "m.federate"
            case roomVersion = "room_version"
            
            case type
        }
        
        public enum RoomType: String, Decodable {
            case space = "m.space"
            case unknown
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self = RoomType(rawValue: (try? container.decode(String.self)) ?? "" ) ?? .unknown
            }
        }
    }
}
