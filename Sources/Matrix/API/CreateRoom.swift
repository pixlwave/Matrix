import Foundation

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
