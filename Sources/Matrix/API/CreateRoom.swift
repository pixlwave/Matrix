import Foundation

struct CreateRoomBody: Encodable {
    let name: String
    let roomAliasName: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case roomAliasName = "room_alias_name"
    }
}


public struct CreateRoomResponse: Decodable {
    public let roomID: String
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
    }
}
