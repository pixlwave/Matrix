import Foundation

public enum MatrixError: Error {
    case urlError(error: URLError)
    case decodeError(error: DecodingError)
    case errorResponse(error: ErrorResponse)
    case unknown(error: Error)
    
    public var description: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodeError(let error):
            return error.localizedDescription
        case .errorResponse(let error):
            return error.message
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
