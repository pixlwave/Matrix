import Foundation

extension Data {
    func decode<T>(_ type: T.Type) -> Result<T, ErrorResponse> where T: Decodable {
        if let response = try? JSONDecoder().decode(T.self, from: self) {
            return .success(response)
        } else if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: self){
            return .failure(errorResponse)
        } else {
            return .failure(ErrorResponse(code: "Unknown", message: String(data: self, encoding: .utf8) ?? "Could not decode response"))
        }
    }
}
