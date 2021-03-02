import Foundation

struct RoomEvent: Codable {
    let content: RoomEventContent
    let type: String
    let eventID: String
    let sender: String
    let timestamp: TimeInterval
//    let unsigned: UnsignedData
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case timestamp = "origin_server_ts"
    }
    
    struct RoomEventContent: Codable {
        let body: String?
    }
}
