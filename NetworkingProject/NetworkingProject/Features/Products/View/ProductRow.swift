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
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(product.category.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if product.discountPercentage > 0 {
                        Text("\(product.discountPercentage, specifier: "%.0f")% off")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                Text("\(product.rating, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}


#Preview {
    List {
        ProductRow(product: .example)
    }
}
