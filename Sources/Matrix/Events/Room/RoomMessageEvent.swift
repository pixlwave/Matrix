import Foundation

public struct RoomMessageEvent: RoomEvent {
    public static var type = "m.room.message"
    
    public let content: MessageContent
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
}
