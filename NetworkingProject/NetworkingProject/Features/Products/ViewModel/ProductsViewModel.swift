import SwiftUI

import Foundation

@Observable class ProductsViewModel {
    
    enum LoadingState: Equatable {
        case initial
        case loading
        case loadingMore
        case loaded
        case initialLoadError(String)
        case loadMoreError(String)
        
        var canLoad: Bool {
            switch self {
            case .initial:
                true
            case .loading:
                false
            case .loadingMore:
                false
            case .loaded:
                true
            case .initialLoadError(_):
                true
            case .loadMoreError(_):
                true
            }
        }
        
        var isCurrentlyLoading: Bool {
            switch self {
            case .loading, .loadingMore: true
            default: false
            }
        }
    }
    
    enum FetchIntents {
        case initial    // onAppear - load if empty
        case loadMore   // scrolling - load next page
        case search     // typing - debounced - reload
        case filterChanged // sheet dismissed - reload
        case retry         // error button - reload
        
        var shouldDebounce: Bool {
            self == .search
        }
        
        var resetProducts: Bool {
            switch self {
            case  .loadMore: return false
            case .initial, .search, .filterChanged, .retry: return true
            }
        }
    }
    
    private(set) var products: [Product] = []
    private(set) var loadingState: LoadingState = .initial
    
    var configuration: ProductsEndpoint.Configuration = .init()
    private var previousConfiguration: ProductsEndpoint.Configuration? = nil
    
    private var totalProductCount: Int? = nil
    private let service: ProductsService
    
    private let pageSize: Int = 20
    private var task: Task<(), Error>? = nil
    
    init(service: ProductsService = DefaultProductsService()) {
        self.service = service
    }
    
    // Explicit @MainActor required to silence compiler warning.
    // This method is always called from the UI (already on MainActor),
    // but Swift's strict concurrency checking in Swift 6 mode requires
    // the annotation to verify isolation at Task boundaries.
    @MainActor
    func load(for intent: FetchIntents) {
        guard canLoad(for: intent) else { return }
        
        self.task?.cancel()
        
        self.task = Task {
            await self.performLoad(for: intent)
        }
    }
    
    func stopFetch() {
        task?.cancel()
        loadingState = products.isEmpty ? .initial : .loaded
    }
    
    private func performLoad(for intent: FetchIntents) async {
        
        // Skip debounce when search is cleared so the list resets immediately
        if intent.shouldDebounce, !configuration.searchText.isEmpty {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
        }
        
        loadingState = intent.resetProducts ? .loading : .loadingMore
        
        do {
            
            print("load started - \(intent)")
            let skip = intent.resetProducts ? 0 : products.count
            let response = try await service.fetch(skip: skip,
                                                   limit: pageSize,
                                                   configuration: configuration)
            
            guard !Task.isCancelled else { return }
            
            if intent.resetProducts {
                self.products = response.products
            } else {
                self.products.append(contentsOf: response.products)
            }
            self.totalProductCount = response.total
            print("load ended - \(intent)")
            self.loadingState = .loaded
            self.previousConfiguration = configuration
        } catch APIError.taskCancellation {
            // ignore task cancellation errors thrown from URLSession
            return
        } catch {
            if loadingState == .loading {
                self.loadingState = .initialLoadError(error.localizedDescription)
            } else {
                self.loadingState = .loadMoreError(error.localizedDescription)
            }
        }
    }
    
    private func canLoad(for intent: FetchIntents) -> Bool {
        switch intent {
        case .initial:
            //  if you successfully load products and then the view calls onAppear again (e.g., tab switching), it won't reload.
            products.isEmpty && !loadingState.isCurrentlyLoading
        case .loadMore:
            !loadingState.isCurrentlyLoading  && hasMoreProductsToLoad()
        case .search, .filterChanged:
            // prevent fetch for same filter settings again, but start fetch even if we are already loading
            previousConfiguration != configuration
        case .retry:
            true
        }
    }
    
    func hasMoreProductsToLoad() -> Bool {
        guard let totalProductCount else { return false }
        return products.count < totalProductCount
    }
}

import Playgrounds

import Playgrounds

#Playground("initial") {
    let vm = ProductsViewModel()
    
    await vm.load(for: .initial)
    
    await vm.load(for: .loadMore)
    
    print(vm.loadingState)
    
    print(vm.products.count)
    for product in vm.products {
        print(product.id)
    }
}
