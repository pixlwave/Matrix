import Foundation

public struct RoomNameEvent: RoomEvent {
    public static var type = "m.room.name"
    
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
        public let name: String?
    }
}
