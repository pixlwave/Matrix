import Foundation

public struct MembersResponse: Codable {
    public let members: [RoomEvent]
    
    enum CodingKeys: String, CodingKey {
        case members = "chunk"
    }
}
