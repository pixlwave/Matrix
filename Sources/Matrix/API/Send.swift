import Foundation

struct SendMessageBody: Codable {
    let type: String
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case type = "msgtype"
        case body
    }
}


struct SendReactionBody: Codable {
    let relationship: Relationship
    
    enum CodingKeys: String, CodingKey {
        case relationship = "m.relates_to"
    }
}


struct Relationship: Codable {
    let type: RelationshipType?
    let eventID: String?
    let key: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "rel_type"
        case eventID = "event_id"
        case key
    }
    
    enum RelationshipType: String, Codable {
        case annotation = "m.annotation"
        case replace = "m.replace"
        case reference = "m.reference"
    }
}

struct SendResponse: Codable {
    let eventID: String
    
    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
    }
}
