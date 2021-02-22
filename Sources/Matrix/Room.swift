import Foundation

public struct Room: Identifiable {
    public let id: String
    public var events: [Event]
}
