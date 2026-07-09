import Foundation

struct APIClient {
    
    let baseURL: URL
    
    init(baseURL: URL = URL(string: "https://dummyjson.com")!) {
        self.baseURL = baseURL
    }
    
    @concurrent
    func fetch<E: Endpoint>(endpoint: E) async throws -> E.Response {
        let request = try endpoint.makeRequest(baseURL: baseURL)
        print(request.url?.absoluteString ?? "")
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw APIError.taskCancellation
        } catch is CancellationError {
            throw APIError.taskCancellation
        } catch {
            throw APIError.networkError(error)
        }
        
        //STEP 2
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("error \(httpResponse.statusCode)")
            
            let serverError = try JSONDecoder().decode(ServerError.self, from: data)
            
            throw APIError.requestFailed(statusCode: httpResponse.statusCode,
                                         message: serverError.message)
            
            // 404 - does not exist
            // 401 - auth problems
            // 429 - rate limited
            // 500...599 server erros
        }
        
        return try endpoint.map(data)
    }
}

