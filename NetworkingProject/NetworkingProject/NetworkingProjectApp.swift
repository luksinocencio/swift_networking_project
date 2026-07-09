import SwiftUI

@main
struct NetworkingProjectApp: App {
    @State private var productsViewModel = ProductsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ProductsListView(productsVM: productsViewModel)
        }
    }
}
