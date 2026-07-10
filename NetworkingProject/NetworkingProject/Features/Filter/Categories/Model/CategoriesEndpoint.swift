import Foundation

struct CategoriesEndpoint: Endpoint {
    typealias Response = [String]
    
    let method: HTTPMethod = .get
    var path: String { "/products/category-list" }
    var queryItems: [URLQueryItem] { [] }
}
