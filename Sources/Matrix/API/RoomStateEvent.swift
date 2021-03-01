import Foundation

struct StateEvent: Codable {
    let content: StateEventContent
    let type: String
    let eventID: String
    let sender: String
    let timestamp: Int
//    let unsigned: UnsignedData
    let stateKey: String
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case timestamp = "origin_server_ts"
        case stateKey = "state_key"
    }
    
    struct StateEventContent: Codable {
        let avatarURL: String?
        let displayName: String?
        let membership: Membership?
        let isDirect: Bool?
        
        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatar_url"
            case displayName = "displayname"
            case membership
            case isDirect = "is_direct"
        }
        
        enum Membership: String, Codable {
            case invite, join, knock, leave, ban
        }
    }
}
