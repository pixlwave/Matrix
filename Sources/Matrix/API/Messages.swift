import Foundation

public struct MessagesResponse: Decodable {
    public let startToken: String?
    public let endToken: String?
    @RoomEventArray
    public var events: [RoomEvent]?
    @RoomEventArray
    public var stateEvents: [RoomEvent]?
    
    enum CodingKeys: String, CodingKey {
        case startToken = "start"
        case endToken = "end"
        case events = "chunk"
        case stateEvents = "state"
    }
}
