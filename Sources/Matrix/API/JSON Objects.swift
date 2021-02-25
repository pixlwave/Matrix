import Foundation

struct RegisterUserBody: Codable {
    let username: String
    let password: String
    let auth: [String: String]
}


struct RegisterUserResponse: Codable {
    let accessToken: String
    let homeServer: String
    let userID: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case homeServer = "home_server"
        case userID = "user_id"
    }
}


struct LoginUserBody: Codable {
    let type: String
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case username = "user"
        case password
    }
}


struct LoginUserResponse: Codable {
    let userID: String
    let accessToken: String
    let homeServer: String
    let deviceID: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case accessToken = "access_token"
        case homeServer = "home_server"
        case deviceID = "device_id"
    }
}


struct CreateRoomBody: Codable {
    let name: String
    let roomAliasName: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case roomAliasName = "room_alias_name"
    }
}


struct CreateRoomResponse: Codable {
    let roomID: String
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
    }
}


struct SendMessageBody: Codable {
    let type: String
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case type = "msgtype"
        case body
    }
}


struct SendMessageResponse: Codable {
    let eventID: String
    
    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
    }
}


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
        
        struct StateEvent: Codable {
            let content: StateEventContent
            let type: String
            let eventID: String
            let sender: String
            let timestamp: Int
//            let unsigned: UnsignedData
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
        
        struct RoomEvent: Codable {
            let content: RoomEventContent
            let type: String
            let eventID: String
            let sender: String
            let timestamp: Int
//            let unsigned: UnsignedData
            
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
    }
}


struct RoomNameResponse: Codable {
    let name: String
}
