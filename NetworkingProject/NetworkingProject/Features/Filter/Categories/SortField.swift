import Foundation

enum SortField: String, CaseIterable, Identifiable {
    case title
    case priceAsc
    case priceDesc
    case rating
    case stock
    case discount
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .title:
            "Name"
        case .priceAsc:
            "Lower Price"
        case .priceDesc:
            "Highest Price"
        case .rating:
            "Rating"
        case .stock:
            "Stock"
        case .discount:
            "Discount"
        }
    }
    
    static let defaultSortField: SortField = .title
}
