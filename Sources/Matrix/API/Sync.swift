import Foundation

public struct SyncResponse: Codable {
    public let nextBatch: String
    public let rooms: Rooms
//    public let presence: Presence
//    public let account_data: AccountData
//    public let to_device: ToDevice
//    public let device_lists: DeviceLists
//    public let device_one_time_keys_count: OneTimeKeysCount
    
    enum CodingKeys: String, CodingKey {
        case nextBatch = "next_batch"
        case rooms
    }
    
    public struct Rooms: Codable {
        public let joined: [String: JoinedRooms]
//        public let invite: InvitedRooms
//        public let leave: LeftRooms
        
        enum CodingKeys: String, CodingKey {
            case joined = "join"
        }
    }
}


public struct JoinedRooms: Codable {
    public let summary: RoomSummary?
    public let state: State
    public let timeline: Timeline
//    public let ephemeral: Ephemeral
//    public let account_data: AccountData
    public let unreadNotifications: UnreadNotificationCounts
    
    enum CodingKeys: String, CodingKey {
        case summary
        case state
        case timeline
        case unreadNotifications = "unread_notifications"
    }
    
    public struct RoomSummary: Codable {
        public let heroes: [String]?
        public let joinedMemberCount: Int?
        public let invitedMemberCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case heroes = "m.heroes"
            case joinedMemberCount = "m.joined_member_count"
            case invitedMemberCount = "m.invited_member_count"
        }
    }
    
    public struct State: Codable {
        public let events: [RoomEvent]
    }
    
    public struct Timeline: Codable {
        public let events: [RoomEvent]
        public let isLimited: Bool
        public let previousBatch: String?
        
        enum CodingKeys: String, CodingKey {
            case events
            case isLimited = "limited"
            case previousBatch = "prev_batch"
        }
    }
    
    public struct UnreadNotificationCounts: Codable {
        public let highlightCount: Int
        public let notificationCount: Int
        
        enum CodingKeys: String, CodingKey {
            case highlightCount = "highlight_count"
            case notificationCount = "notification_count"
        }
    }
}
