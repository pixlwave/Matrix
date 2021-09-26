import Foundation

public enum Membership: String, Decodable {
    case invite, join, knock, leave, ban, unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Membership(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
    }
}
