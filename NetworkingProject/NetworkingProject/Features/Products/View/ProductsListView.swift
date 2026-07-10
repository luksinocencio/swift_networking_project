import SwiftUI

struct ProductsListView: View {
    let productsVM: ProductsViewModel
    @State private var searchText = ""
    @State private var filterSheetIsOpen = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(productsVM.products) { product in
                    ProductRow(product: product)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Products")
            .toolbar(content: {
                Toggle(isOn: $filterSheetIsOpen) {
                    Label("Show Filter", systemImage: "slider.horizontal.3")
                }
            })
            .sheet(isPresented: $filterSheetIsOpen, content: {
                FilterProductsView()
            })
            .searchable(text: $searchText)
            .overlay(alignment:.bottom, content: {
                switch productsVM.loadingState {
                case .initial, .loading:
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxHeight: .infinity)
                case .loaded:
                    if productsVM.products.isEmpty {
                        ContentUnavailableView("Nothing Found", systemImage: "basket")
                    }
                case .loadingMore:
                    ProgressView()
                        .controlSize(.small)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                case .initialLoadError(let error):
                    Text(error)
                        .foregroundColor(.red)
                case .loadMoreError(_):
                    EmptyView()
                }
            })
            .task(id: searchText, {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                
                await productsVM.fetch(for: searchText)
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
}

#Preview("API calls") {
    @State @Previewable var vm = ProductsViewModel()
    ProductsListView(productsVM: vm)
}

#Preview("Happy Path") {
    @State @Previewable var vm = ProductsViewModel(service: MockProductsService())
    ProductsListView(productsVM: vm)
}

#Preview("Unhappy Path") {
    @State @Previewable var vm = ProductsViewModel(service: MockProductsService(error: .invalidResponse))
    ProductsListView(productsVM: vm)
}
