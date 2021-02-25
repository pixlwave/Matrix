import Foundation

public class Room: ObservableObject, Identifiable {
    public let id: String
    @Published public var name: String?
    @Published public var events: [Event]
    
    @Published public var members: [Member]
    
    init(id: String, name: String? = nil, events: [Event], members: [Member]) {
        self.id = id
        self.name = name
        self.events = events
        self.members = members
    }
}
