import Foundation

struct ProductsEndpoint: Endpoint {
    typealias Response = ProductResponse
    
    let path: String = "/products"
    let method: HTTPMethod = .get
    
    var limit: Int
    var skip: Int
    
    var queryItems: [URLQueryItem] {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
        
        return items
    }
}
