import SwiftUI

@Observable class ProductsViewModel {
    
    enum LoadingState {
        case initial
        case loading
        case loadingMore
        case loaded
        case initialLoadError(String)
        case loadMoreError(String)
        
        var canLoad: Bool {
            switch self {
            case .initial:
                true
            case .loading:
                false
            case .loadingMore:
                false
            case .loaded:
                true
            case .initialLoadError(_):
                true
            case .loadMoreError(_):
                true
            }
        }
    }
    
    private(set) var products: [Product] = []
    private(set) var loadingState: LoadingState = .initial
    
    private var previousSearch: String? = nil
    
    var totals: Int?
    let service: ProductsService
    
    private let limits: Int = 20
    
    init(service:ProductsService = DefaultProdcutsService()) {
        self.service = service
    }
    
    func initialFetchProducts() async {
        guard products.isEmpty else { return }
        
        loadingState = .loading
        
        do {
            let response = try await service.fetch(skip: 0, limit: limits, searchQuery: nil)
            self.products = response.products
            self.totals = response.total
            self.loadingState = .loaded
        } catch {
            self.loadingState = .initialLoadError(error.localizedDescription)
        }
    }
    
    func fetchMore() async {
        guard totals != products.count, loadingState.canLoad else { return }
        
        loadingState = .loadingMore
        
        do {
            let response = try await service.fetch(skip: products.count, limit: 10, searchQuery: previousSearch)
            self.totals = response.total
            self.products.append(contentsOf: response.products)
            self.loadingState = .loaded
        } catch {
            self.loadingState = .loadMoreError(error.localizedDescription)
        }
    }
    
    func fetch(for searchQuery: String) async {
        guard (previousSearch ?? "") != searchQuery else { return }
        
        loadingState = .loading
        products = []
        
        do {
            let response = try await service.fetch(skip: 0, limit: limits, searchQuery: searchQuery)
            self.products = response.products
            self.totals = response.total
            self.loadingState = .loaded
            self.previousSearch = searchQuery
        } catch APIError.taskCancellation {
            //ignore
        } catch {
            self.loadingState = .initialLoadError(error.localizedDescription)
        }
    }
}

import Playgrounds

#Playground {
    let vm = ProductsViewModel(service: MockProductsService())
    await vm.initialFetchProducts()
}
