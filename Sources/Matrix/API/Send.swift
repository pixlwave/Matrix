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


public struct Relationship: Codable {
    public let type: RelationshipType?
    public let eventID: String?
    public let key: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "rel_type"
        case eventID = "event_id"
        case key
    }
    
    public enum RelationshipType: String, Codable {
        case annotation = "m.annotation"
        case replace = "m.replace"
        case reference = "m.reference"
    }
}

// implement a custom decoder that will set type to nil if
// the string received can't be decoded as a RelationshipType.
extension Relationship {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let type = try? container.decodeIfPresent(RelationshipType.self, forKey: .type) {
            self.type = type
        } else {
            self.type = nil
        }
        
        self.eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        self.key = try container.decodeIfPresent(String.self, forKey: .key)
    }
}

public struct SendResponse: Codable {
    public let eventID: String
    
    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
    }
}
