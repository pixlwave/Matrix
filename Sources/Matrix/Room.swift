import Foundation

public struct Room: Identifiable {
    public let id: String
    public let events: [Event]
}
