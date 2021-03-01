import Foundation

struct SyncResponse: Codable {
    let nextBatch: String
    let rooms: Rooms
//    let presence: Presence
//    let account_data: AccountData
//    let to_device: ToDevice
//    let device_lists: DeviceLists
//    let device_one_time_keys_count: OneTimeKeysCount
    
    enum CodingKeys: String, CodingKey {
        case nextBatch = "next_batch"
        case rooms
    }
    
    struct Rooms: Codable {
        let joined: [String: JoinedRooms]
//        let invite: InvitedRooms
//        let leave: LeftRooms
        
        enum CodingKeys: String, CodingKey {
            case joined = "join"
        }
    }
}


struct JoinedRooms: Codable {
    let summary: RoomSummary?
    let state: State
    let timeline: Timeline
//    let ephemeral: Ephemeral
//    let account_data: AccountData
//    let unread_notifications: UnreadNotificationCounts
    
    struct RoomSummary: Codable {
        let heroes: [String]?
        let joinedMemberCount: Int?
        let invitedMemberCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case heroes = "m.heroes"
            case joinedMemberCount = "m.joined_member_count"
            case invitedMemberCount = "m.invited_member_count"
        }
    }
    
    struct State: Codable {
        let events: [StateEvent]
    }
    
    struct Timeline: Codable {
        let events: [RoomEvent]
        let isLimited: Bool
        let previousBatch: String?
        
        enum CodingKeys: String, CodingKey {
            case events
            case isLimited = "limited"
            case previousBatch = "prev_batch"
        }
    }
}
