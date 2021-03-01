import Foundation

public struct Member {
    public let userID: String
    public let displayName: String?
    public let avatarURL: URL?
    
    init(userID: String, displayName: String?, avatarURL: URL?) {
        self.userID = userID
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
    
    init(event: StateEvent) {
        self.userID = event.stateKey
        self.displayName = event.content.displayName
        
        if let urlString = event.content.avatarURL, var components = URLComponents(string: urlString) {
            components.scheme = "https"
            self.avatarURL = components.url
        } else {
            self.avatarURL = nil
        }
    }
}
