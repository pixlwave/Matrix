import Foundation

extension Data {
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: self) {
                throw errorResponse
            } else {
                throw error
            }
        }
    }
}
