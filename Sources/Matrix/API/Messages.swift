import Foundation

struct MessagesResponse: Codable {
    let startToken: String?
    let endToken: String?
    let events: [RoomEvent]?
    let stateEvents: [StateEvent]?
    
    enum CodingKeys: String, CodingKey {
        case startToken = "start"
        case endToken = "end"
        case events = "chunk"
        case stateEvents = "state"
    }
}
