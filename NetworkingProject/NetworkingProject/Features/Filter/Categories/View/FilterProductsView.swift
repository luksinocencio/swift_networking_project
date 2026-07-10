import SwiftUI

struct FilterProductsView: View {
    @State private var categoryViewModel = CategoriesViewModel()
    @State private var sortOrder = SortField.defaultSortField
    @State private var selectedCategory: String? = ""
    
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationStack {
            List {
                Picker("Sort By", selection: $sortOrder) {
                    ForEach(SortField.allCases) {
                        Text($0.displayName)
                    }
                }.pickerStyle(.inline)
                
                Picker("Categories", selection: $selectedCategory) {
                    ForEach(categoryViewModel.categories, id: \.self) { category in
                        Text(category.capitalized)
                    }
                }.pickerStyle(.inline)
            }
            .navigationBarTitle("Filter Products", displayMode: .inline)
            .toolbar(content: {
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
            })
            .task {
                await categoryViewModel.fetchCategories()
            }
        }
    }
}

#Preview {
    FilterProductsView()
}
