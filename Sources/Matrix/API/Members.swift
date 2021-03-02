import Foundation

struct Members: Codable {
    let members: [StateEvent]
    
    enum CodingKeys: String, CodingKey {
        case members = "chunk"
    }
}
