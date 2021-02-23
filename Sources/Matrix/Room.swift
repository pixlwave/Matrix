import Foundation

public class Room: ObservableObject, Identifiable {
    public let id: String
    public var name: String?
    @Published public var events: [Event]
    
    init(id: String, name: String? = nil, events: [Event]) {
        self.id = id
        self.name = name
        self.events = events
    }
}
