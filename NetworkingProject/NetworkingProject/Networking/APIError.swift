import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    case networkError(Error)
    case taskCancellation
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Something went wrong. Please try again."
        case .networkError(_):
            "Something went wrong. Please try again."
        case .requestFailed(_, _):
            "Something went wrong. Please try again."
        case .taskCancellation:
            "Task was cancelled"
        case .invalidURL:
            "Invalid URL"
            
        }
    }
}

struct ServerError: Decodable {
    let message: String
}
