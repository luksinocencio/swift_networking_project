import SwiftUI

struct ProductsListView: View {
    let productsVM: ProductsViewModel
    
    var body: some View {
        List {
            ForEach(productsVM.products) { product in
                Text(product.title)
            }
        }
        .overlay(content: {
            if let error = productsVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        })
        .task {
            await productsVM.fetchProducts()
        }
    }
}

#Preview("Happy Path") {
    @State @Previewable var vm = ProductsViewModel(service: MockProdcutsService())
    ProductsListView(productsVM: vm)
}

#Preview("Unhappy Path") {
    @State @Previewable var vm = ProductsViewModel(service: MockProdcutsService(error: .invalidResponse))
    ProductsListView(productsVM: vm)
}
