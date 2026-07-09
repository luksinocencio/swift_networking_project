import SwiftUI

@Observable class ProductsViewModel {
    var products: [Product] = []
    var errorMessage: String?
    
    let service: ProductsService
    
    init(service:ProductsService = DefaultProdcutsService()) {
        self.service = service
    }
    
    func fetchProducts() async {
        do {
            self.products = try await service.fetch(skip: 10, limit: 10)
        } catch {
            self.errorMessage = error.localizedDescription

        }
    }
}

import Playgrounds

#Playground {
    let vm = ProductsViewModel(service: MockProdcutsService())
    await vm.fetchProducts()
}
