import SwiftUI

struct ProductsListView: View {
    
    @Bindable var productsVM: ProductsViewModel
    
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
                Button {
                    filterSheetIsOpen.toggle()
                } label: {
                    Label("Show Filter", systemImage: "slider.horizontal.3")
                }
            })
            .sheet(isPresented: $filterSheetIsOpen, onDismiss: {
                print("start the new fetch if something changed")
                productsVM.load(for: .filterChanged)
            }, content: {
                FilterProductsView(sortOrder: $productsVM.configuration.sortField, selectedCategory: $productsVM.configuration.category)
            })
            
            .searchable(text: $productsVM.configuration.searchText)
            .overlay(alignment: .bottom, content: {
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
                        .controlSize(.extraLarge)
                        .padding()
                    
                case .initialLoadError(let error):
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.title)
                        
                        Button("Retry") {
                            productsVM.load(for: .retry)
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                case .loadMoreError(let error):
                    // smaller overlay
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(.thinMaterial).cornerRadius(5).shadow(radius: 5)
                }
                
            })
            .onChange(of: productsVM.configuration.searchText, { oldValue, newValue in
                productsVM.load(for: .search)
            })
            .onAppear {
                productsVM.load(for: .initial)
            }
            .onTriggerLoadAt(triggerDistance: 300, of: {
                productsVM.load(for: .loadMore)
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
