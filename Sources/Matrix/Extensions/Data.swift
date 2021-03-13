import Foundation

extension Data {
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: self) {
                throw errorResponse
            } else {
                throw error
            }
        }
    }
}
