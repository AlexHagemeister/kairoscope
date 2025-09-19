import SwiftUI

struct TimelineShellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimelineShellView()
                .previewDisplayName("Portrait")
                .previewDevice("iPhone 15 Pro")

            TimelineShellView()
                .previewDisplayName("Landscape")
                .previewLayout(.fixed(width: 812, height: 375))
        }
    }
}
