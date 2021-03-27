import Foundation

public struct MessagesResponse: Codable {
    public let startToken: String?
    public let endToken: String?
    public let events: [RoomEvent]?
    public let stateEvents: [RoomEvent]?
    
    enum CodingKeys: String, CodingKey {
        case startToken = "start"
        case endToken = "end"
        case events = "chunk"
        case stateEvents = "state"
    }
}
