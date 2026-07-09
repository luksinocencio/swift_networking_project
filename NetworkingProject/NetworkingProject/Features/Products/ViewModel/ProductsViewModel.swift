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
            case .initialLoadError(let string):
                true
            case .loadMoreError(let string):
                true
            }
        }
    }
    
    private(set) var products: [Product] = []
    var loadingState: LoadingState = .initial
    var totals: Int?
    
    let service: ProductsService
    
    init(service:ProductsService = DefaultProdcutsService()) {
        self.service = service
    }
    
    func initialFetchProducts() async {
        guard products.isEmpty else { return }
        
        loadingState = .loading
        
        do {
//            try await Task.sleep(for: .milliseconds(500))
            let response = try await service.fetch(skip: 0, limit: 10)
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
//            try await Task.sleep(for: .seconds(1))
            let response = try await service.fetch(skip: products.count, limit: 10)
            self.totals = response.total
            self.products.append(contentsOf: response.products)
            self.loadingState = .loaded
        } catch {
            self.loadingState = .loadMoreError(error.localizedDescription)
        }
    }
}

import Playgrounds

#Playground {
    let vm = ProductsViewModel(service: MockProdcutsService())
    await vm.initialFetchProducts()
}
