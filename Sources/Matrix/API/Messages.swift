import Foundation

public struct MessagesResponse: Decodable {
    public let startToken: String?
    public let endToken: String?
    @DecodableRoomEvents
    public var events: [RoomEvent]?
    @DecodableRoomEvents
    public var stateEvents: [RoomEvent]?
    
    enum CodingKeys: String, CodingKey {
        case startToken = "start"
        case endToken = "end"
        case events = "chunk"
        case stateEvents = "state"
    }
}
