import Foundation

struct CategoriesEndpoint: Endpoint {
    typealias Response = [String]
    
    let path: String = "/prodcuts/category-list"
    let method: HTTPMethod = .get
    
    var queryItems: [URLQueryItem] {
        let items: [URLQueryItem] = []
        return items
    }
}
