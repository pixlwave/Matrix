import Foundation

public struct MembersResponse: Codable {
    public let members: [StateEvent]
    
    enum CodingKeys: String, CodingKey {
        case members = "chunk"
    }
}
