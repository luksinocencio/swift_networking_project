import SwiftUI

struct ProductsListView: View {
    let productsVM: ProductsViewModel
    
    var body: some View {
        List {
            ForEach(productsVM.products) { product in
                ProductRow(product: product)
            }
        }
        .overlay(content: {
            if let error = productsVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            if productsVM.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
        })
        .task {
            await productsVM.initialFetchProducts()
        }
        .onTriggerLoadAt(triggerDistance: 300, of: {
            Task {
                await productsVM.fetchMore()
            }
        })
    }
}

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack {
            Text(product.id.description)
            Text(product.title)
        }.padding(40)
    }
}

extension View {
    func onTriggerLoadAt(triggerDistance: CGFloat, of transform: @escaping () -> Void) -> some View {
        return self
            .onScrollGeometryChange(for: Bool.self) { geometry in
                guard geometry.contentSize.height > 0 else { return false }
                
                let maxOffset = geometry.contentSize.height - geometry.containerSize.height
                
                let currentOffset = geometry.contentOffset.y
                let triggerDistance: CGFloat = 300
                return currentOffset >= maxOffset - triggerDistance
            } action: { wasNearBottom, isNearBottom in
                guard isNearBottom else { return }
                if isNearBottom && !wasNearBottom {
                    transform()
                }
            }
        
    }
}

#Preview("Happy Path") {
    @State @Previewable var vm = ProductsViewModel(service: DefaultProdcutsService())
    ProductsListView(productsVM: vm)
}

//#Preview("Happy Path") {
//    @State @Previewable var vm = ProductsViewModel(service: MockProdcutsService())
//    ProductsListView(productsVM: vm)
//}

#Preview("Unhappy Path") {
    @State @Previewable var vm = ProductsViewModel(service: MockProdcutsService(error: .invalidResponse))
    ProductsListView(productsVM: vm)
}
