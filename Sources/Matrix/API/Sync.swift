import Foundation

public struct SyncResponse: Decodable {
    public let nextBatch: String
    public let rooms: Rooms?
//    public let presence: Presence
//    public let account_data: AccountData
//    public let to_device: ToDevice
//    public let device_lists: DeviceLists
//    public let device_one_time_keys_count: OneTimeKeysCount
    
    enum CodingKeys: String, CodingKey {
        case nextBatch = "next_batch"
        case rooms
    }
    
    public struct Rooms: Decodable {
        public let joined: [String: JoinedRoom]?
//        public let invite: [String: InvitedRoom]?
        public let left: [String: LeftRoom]?
        
        enum CodingKeys: String, CodingKey {
            case joined = "join"
            case left = "leave"
        }
    }
}


public struct JoinedRoom: Decodable {
    public let summary: RoomSummary?
    public let state: State?
    public let timeline: Timeline?
//    public let ephemeral: Ephemeral?
//    public let account_data: AccountData?
    public let unreadNotifications: UnreadNotificationCounts?
    
    enum CodingKeys: String, CodingKey {
        case summary
        case state
        case timeline
        case unreadNotifications = "unread_notifications"
    }
    
    public struct RoomSummary: Decodable {
        public let heroes: [String]?
        public let joinedMemberCount: Int?
        public let invitedMemberCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case heroes = "m.heroes"
            case joinedMemberCount = "m.joined_member_count"
            case invitedMemberCount = "m.invited_member_count"
        }
    }
    
    public struct State: Decodable {
        @RoomEventArray
        public var events: [RoomEvent]?
    }
    
    public struct Timeline: Decodable {
        @RoomEventArray
        public var events: [RoomEvent]?
        public let isLimited: Bool?
        public let previousBatch: String?
        
        enum CodingKeys: String, CodingKey {
            case events
            case isLimited = "limited"
            case previousBatch = "prev_batch"
        }
    }
    
    public struct UnreadNotificationCounts: Decodable {
        public let highlightCount: Int?
        public let notificationCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case highlightCount = "highlight_count"
            case notificationCount = "notification_count"
        }
    }
}


public struct LeftRoom: Decodable {
//    public let state: State
//    public let timeline: Timeline
//    public let account_data: AccountData
}
