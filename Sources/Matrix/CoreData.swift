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
        self.sender = roomEvent.sender
        self.date = Date(timeIntervalSince1970: roomEvent.timestamp / 1000)
    }
}
