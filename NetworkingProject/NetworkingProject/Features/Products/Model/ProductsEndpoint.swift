import Foundation

struct ProductsEndpoint: Endpoint {
    typealias Response = ProductResponse
    
    var path: String {
        if searchQuery != nil {
            "/products/search"
        } else {
            "/products"
        }
    }
    
    let method: HTTPMethod = .get
    
    var limit: Int
    var skip: Int
    var searchQuery: String?
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
        
        if let searchQuery {
            items.append(.init(name: "q", value: searchQuery))
        }
        
        return items
    }
}
