import CoreData

extension RoomObj {
    public var hasMoreMessages: Bool { previousBatch != nil }
    
    convenience init(id: String, joinedRoom: JoinedRooms, context: NSManagedObjectContext) {
        let messages = joinedRoom.timeline.events.filter { $0.type == "m.room.message" }
                                                 .compactMap { MessageObj(roomEvent: $0, context: context) }
        
        self.init(context: context)
        self.id = id
        self.messages = self.messages?.addingObjects(from: messages) as NSSet?
        self.previousBatch = joinedRoom.timeline.previousBatch
    }
}


extension MessageObj {
    convenience init?(roomEvent: RoomEvent, context: NSManagedObjectContext) {
        guard let body = roomEvent.content.body else { return nil }
        
        self.init(context: context)
        self.body = body
        self.id = roomEvent.eventID
        self.sender = MemberObj(userID: roomEvent.sender, context: context)
        self.date = Date(timeIntervalSince1970: roomEvent.timestamp / 1000)
    }
}


extension MemberObj {
    convenience init(userID: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = userID
    }
    
    convenience init(event: StateEvent, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = event.stateKey
        self.displayName = event.content.displayName
        
        if let urlString = event.content.avatarURL, var components = URLComponents(string: urlString) {
            components.scheme = "https"
            self.avatarURL = components.url
        } else {
            self.avatarURL = nil
        }
    }
}
