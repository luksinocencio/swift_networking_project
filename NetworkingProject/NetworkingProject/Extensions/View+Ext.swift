import SwiftUI

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
