import Foundation

public struct Event: Identifiable, Equatable {
    public let id: String
    public let body: String
    public let sender: String
}
