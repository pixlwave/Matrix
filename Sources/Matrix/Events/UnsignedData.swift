import Foundation

public struct UnsignedData: Decodable {
    public let transactionID: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionID = "transaction_id"
    }
}



