import Foundation

protocol ProductsService: Sendable {
    func fetch(skip: Int, limit: Int) async throws -> ProductResponse
}

struct DefaultProdcutsService: ProductsService {
    let client: APIClient
    
    init(baseURL: URL = URL(string: "https://dummyjson.com")!) {
        self.client = APIClient(baseURL: baseURL)
    }
    
    func fetch(skip: Int, limit: Int) async throws -> ProductResponse {
        return try await client.fetch(endpoint: ProductsEndpoint(limit: limit, skip: skip))
    }
}

struct MockProdcutsService: ProductsService {
    let error: APIError?
    let result: [Product]
    
    init(error: APIError? = nil, result: [Product] = [Product.example]) {
        self.error = error
        self.result = result
    }
    
    func fetch(skip: Int, limit: Int) async throws -> ProductResponse {
        if let error {
            throw error
        } else {
            ProductResponse(products: result, total: 100, skip: 0, limit: result.count)
        }
    }
}
