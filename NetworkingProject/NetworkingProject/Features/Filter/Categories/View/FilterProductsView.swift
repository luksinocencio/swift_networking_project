import SwiftUI

struct FilterProductsView: View {
    
    @State private var categoryViewModel = CategoriesViewModel()
    
    @Binding var sortOrder: SortField?
    @Binding var selectedCategory: String?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                
                Picker("Sort By",
                       selection: $sortOrder) {
                    ForEach(SortField.allCases) {
                        Text($0.displayName)
                            .tag($0)
                    }
                }
                       .pickerStyle(.inline)
                
                
                Picker("Categories",
                       selection: $selectedCategory) {
                    ForEach(categoryViewModel.categories, id: \.self) { category in
                        Text(category.capitalized)
                            .tag(category)
                    }
                }
                       .pickerStyle(.inline)
                //TODO: show loading / error feedback for categories
            }
            .navigationTitle("Filter Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        sortOrder = SortField.defaultSortField
                        selectedCategory = nil
                        dismiss()
                    }
                }
            }
        }
        .task {
            await categoryViewModel.fetchCategories()
        }
    }
}

#Preview {
    @State @Previewable var sortOrder: SortField? = .discount
    @State @Previewable var selectedCategory: String? = nil
    
    FilterProductsView(sortOrder: $sortOrder,
                       selectedCategory: $selectedCategory)
}
