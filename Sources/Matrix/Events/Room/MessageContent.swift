import Foundation

public struct MessageContent: Decodable {
    // required
    public let body: String?
    public let type: MessageType?
    
    // optional
    public let relationship: Relationship?
    public let mediaURL: URL?
    public let mediaInfo: MediaInfo?
    
    // edit event
    public let newContent: NewContent?
    
    enum CodingKeys: String, CodingKey {
        case body
        case type = "msgtype"
        case relationship = "m.relates_to"
        case mediaURL = "url"
        case mediaInfo = "info"
        case newContent = "m.new_content"
    }
    
    public struct MediaInfo: Decodable {
        public let width: Int?
        public let height: Int?
        public let mimetype: String?
        public let fileSize: Int?
        
        enum CodingKeys: String, CodingKey {
            case width = "w"
            case height = "h"
            case mimetype
            case fileSize = "size"
        }
    }
    
    public struct NewContent: Decodable {
        public let body: String?
    }
    
    public enum MessageType: String, Decodable {
        case text = "m.text"
        case emote = "m.emote"
        case notice = "m.notice"
        case image = "m.image"
        case file = "m.file"
        case audio = "m.audio"
        case location = "m.location"
        case video = "m.video"
        case unknown
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self = MessageType(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
        }
    }
}
