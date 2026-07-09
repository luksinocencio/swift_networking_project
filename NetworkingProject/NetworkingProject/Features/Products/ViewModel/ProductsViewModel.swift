import SwiftUI

@Observable class ProductsViewModel {
    var products: [Product] = []
    var errorMessage: String?
    var isLoading: Bool = false
    var totals: Int?
    
    let service: ProductsService
    
    init(service:ProductsService = DefaultProdcutsService()) {
        self.service = service
    }
    
    func initialFetchProducts() async {
        guard products.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await Task.sleep(for: .milliseconds(500))
            let response = try await service.fetch(skip: 0, limit: 10)
            self.products = response.products
            self.totals = response.total
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchMore() async {
        guard totals != products.count, !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await Task.sleep(for: .seconds(1))
            let response = try await service.fetch(skip: products.count, limit: 10)
            self.totals = response.total
            self.products.append(contentsOf: response.products)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

import Playgrounds

#Playground {
    let vm = ProductsViewModel(service: MockProdcutsService())
    await vm.initialFetchProducts()
}
