import Foundation

public struct MembersResponse: Decodable {
    @DecodableRoomEvents
    public var members: [RoomEvent]?
    
    enum CodingKeys: String, CodingKey {
        case members = "chunk"
    }
}
