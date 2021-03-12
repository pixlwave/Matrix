import Foundation

public enum MatrixError: Error {
    case urlError(error: URLError)
    case decodeError(error: DecodingError)
    case errorResponse(error: ErrorResponse)
    case unknown(error: Error)
}
