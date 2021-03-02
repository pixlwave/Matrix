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
        let relationship: Relationship?
        let newContent: NewContent?
        
        enum CodingKeys: String, CodingKey {
            case body
            case relationship = "m.relates_to"
            case newContent = "m.new_content"
        }
        
        struct NewContent: Codable {
            let body: String?
        }
    }
}
