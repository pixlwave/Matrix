import Foundation

public struct MembersResponse: Decodable {
    @RoomEventArray
    public var members: [RoomEvent]?
    
    enum CodingKeys: String, CodingKey {
        case members = "chunk"
    }
}
