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
//    let state: State
    let timeline: Timeline
//    let ephemeral: Ephemeral
//    let account_data: AccountData
//    let unread_notifications: UnreadNotificationCounts
    
    struct RoomSummary: Codable {
        let heroes: [String]
        let joinedMemberCount: Int
        let invitedMemberCount: Int
        
        enum CodingKeys: String, CodingKey {
            case heroes = "m.heroes"
            case joinedMemberCount = "m.joined_member_count"
            case invitedMemberCount = "m.invited_member_count"
        }
    }
    
    struct Timeline: Codable {
        let events: [RoomEvent]
        let isLimited: Bool
        let previousBatch: String
        
        enum CodingKeys: String, CodingKey {
            case events
            case isLimited = "limited"
            case previousBatch = "prev_batch"
        }
        
        struct RoomEvent: Codable {
            let content: [String: String]
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
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.type = try container.decode(String.self, forKey: .type)
                self.eventID = try container.decode(String.self, forKey: .eventID)
                self.sender = try container.decode(String.self, forKey: .sender)
                self.timestamp = try container.decode(Int.self, forKey: .timestamp)
                
                // content values aren't always strings, ignore these for now
                let content = try? container.decode([String: String].self, forKey: .content)
                self.content = content ?? [:]
            }
        }
    }
}
