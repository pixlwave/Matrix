import Foundation

struct SendMessageBody: Encodable {
    let type: String
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case type = "msgtype"
        case body
    }
}


struct SendReactionBody: Encodable {
    let relationship: Relationship
    
    enum CodingKeys: String, CodingKey {
        case relationship = "m.relates_to"
    }
}


public struct SendResponse: Decodable {
    public let eventID: String
    
    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
    }
}
