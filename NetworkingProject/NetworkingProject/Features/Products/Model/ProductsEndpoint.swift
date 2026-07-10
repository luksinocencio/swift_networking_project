import Foundation

struct ProductsEndpoint: Endpoint {
    typealias Response = ProductResponse
    
    struct Configuration: Equatable {
        var searchText: String = ""
        var category: String?
        var sortField: SortField?
    }
    
    var path: String {
        if let category = configuration.category {
            "/products/category/\(category)"
        } else if !configuration.searchText.isEmpty {
            "/products/search"
        } else {
            "/products"
        }
    }
    
    let method: HTTPMethod = .get
    
    var limit: Int
    var skip: Int
    var configuration: Configuration
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
        
        // search only applies on /products/search path
        // when category is set, query is ignored
        if configuration.category == nil,
           !configuration.searchText.isEmpty  {
            items.append(URLQueryItem(name: "q", value: configuration.searchText))
        }
        
        if let sortField = configuration.sortField  {
            switch sortField {
            case .title:
                items.append(URLQueryItem(name: "sortBy", value: "title"))
            case .priceAsc:
                items.append(URLQueryItem(name: "sortBy", value: "price"))
                items.append(URLQueryItem(name: "order", value: "asc"))
            case .priceDesc:
                items.append(URLQueryItem(name: "sortBy", value: "price"))
                items.append(URLQueryItem(name: "order", value: "desc"))
            case .rating:
                items.append(URLQueryItem(name: "sortBy", value: "rating"))
                items.append(URLQueryItem(name: "order", value: "desc"))
            case .stock:
                items.append(URLQueryItem(name: "sortBy", value: "stock"))
                items.append(URLQueryItem(name: "order", value: "desc"))
            case .discount:
                items.append(URLQueryItem(name: "sortBy", value: "stock"))
                items.append(URLQueryItem(name: "order", value: "desc"))
            }
        }
        
        return items
    }
}
