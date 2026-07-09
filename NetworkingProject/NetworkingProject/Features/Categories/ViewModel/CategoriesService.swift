import Foundation

protocol CategoriesService {
    func fetch() async throws -> [String]
}

struct DefaultCategoriesService: CategoriesService {
    let client: APIClient
    
    init(baseURL: URL = URL(string: "https://dummyjson.com")!) {
        self.client = APIClient(baseURL: baseURL)
    }
    
    func fetch() async throws -> [String] {
        return try await client.fetch(endpoint: CategoriesEndpoint())
    }
}
