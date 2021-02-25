import Foundation

extension Data {
    func decode<T>(_ type: T.Type) -> Result<T, ErrorResponse> where T: Decodable {
        do {
            let response = try JSONDecoder().decode(T.self, from: self)
            return .success(response)
        } catch let error {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: self){
                return .failure(errorResponse)
            } else {
                // write data to file as this can be huge!
                // print(String(data: self, encoding: .utf8) ?? "Could not decode response")
                print(error)
                return .failure(ErrorResponse(code: "Decode Error", message: error.localizedDescription))
            }
        }
    }
}
