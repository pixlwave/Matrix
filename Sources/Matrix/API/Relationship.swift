import Foundation

public struct Relationship: Codable {
    public let type: RelationshipType
    public let eventID: String?
    public let key: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "rel_type"
        case eventID = "event_id"
        case key
        case reply = "m.in_reply_to"
    }
    
    public enum RelationshipType: String, Codable {
        case annotation = "m.annotation"
        case replace = "m.replace"
        case reference = "m.reference"
        case thread = "m.thread"
        case reply
        case unknown
        
        // implement a custom decoder that will decode as unknown if
        // the string received can't be decoded as one of the cases
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self = RelationshipType(rawValue: (try? container.decode(String.self)) ?? "" ) ?? .unknown
        }
    }
    
    struct Reply: Codable {
        let eventID: String?
        
        enum CodingKeys: String, CodingKey {
            case eventID = "event_id"
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // first check for rel_type style relationship
        if container.contains(.type) && container.contains(.eventID) {
            guard
                let type = try? container.decode(RelationshipType.self, forKey: .type),
                let eventID = try? container.decode(String.self, forKey: .eventID)
            else { self.init(); return }
            
            if type != .annotation {
                self.init(type: type, eventID: eventID)
            } else {
                guard let key = try? container.decodeIfPresent(String.self, forKey: .key) else {
                    self.init(); return
                }
                
                self.init(type: type, eventID: eventID, key: key)
            }
            
        // then check for in_reply_to style relationship
        } else if container.contains(.reply) {
            guard
                let reply = try? container.decode(Reply.self, forKey: .reply),
                let eventID = reply.eventID
            else { self.init(); return }
            
            self.init(type: .reply, eventID: eventID)
            
        // finally fail as unknown if both are missing
        } else {
            self.init()
        }
    }
    
    public init(type: RelationshipType, eventID: String, key: String? = nil) {
        self.type = type
        self.eventID = eventID
        self.key = key
    }
    
    /// Creates a relationship with an unknown type.
    private init() {
        self.type = .unknown
        self.eventID = nil
        self.key = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch type {
        case .unknown:
            // unknown relationship type cannot be encoded
            throw EncodingError.invalidValue(self, .init(codingPath: container.codingPath, debugDescription: "Attempted to encode unknown relationship type", underlyingError: nil))
        case .reply:
            // replies should be handled separately as they have a different format
            try container.encode(Reply(eventID: eventID), forKey: .reply)
        default:
            // everything else follows a common format
            try container.encode(type, forKey: .type)
            try container.encode(eventID, forKey: .eventID)
            try container.encode(key, forKey: .key)
        }
    }
}
