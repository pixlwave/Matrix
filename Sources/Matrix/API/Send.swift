import Foundation

public struct SendResponse: Decodable {
    public let eventID: String
    
    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
    }
}
