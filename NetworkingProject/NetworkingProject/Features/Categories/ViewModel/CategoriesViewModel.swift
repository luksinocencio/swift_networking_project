import Foundation

@Observable class CategoriesViewModel {
    var categories: [String] = []
    let service: CategoriesService
    
    init(service: CategoriesService = DefaultCategoriesService()) {
        self.service = service
    }
    
    func fetchCategories() async {
        let request = URLRequest(url: URL(string: "https://dummyjson.com/products/category-list")!)
        do{
            categories = try await service.fetch()
        } catch {
            print(error)
        }
    }
}



import Playgrounds

#Playground {
    let vm = CategoriesViewModel()
    await vm.fetchCategories()
}
