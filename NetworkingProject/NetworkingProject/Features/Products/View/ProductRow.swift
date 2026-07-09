import SwiftUI

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.thumbnail)) { phase in
                switch phase {
                case .empty:
                    Color.gray
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure(_):
                    Color.gray
                @unknown default:
                    fatalError()
                }
            }
            .frame(width: 100, height: 100)
            .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading) {
                Text(product.title)
                    .bold()
                Text(product.category.capitalized)
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    List {
        ProductRow(product: .example)
    }
}
