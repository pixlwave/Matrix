import Foundation

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
        case unknown
        
        // implement a custom decoder that will decode as unknown if
        // the string received can't be decoded as one of the cases
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self = RelationshipType(rawValue: (try? container.decode(String.self)) ?? "" ) ?? .unknown
        }
    }
}
