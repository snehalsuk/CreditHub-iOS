import SwiftUI

enum DesignSystem {
    enum Colors {
        static let primary = Color("BrandPrimary")
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Typography {
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let caption = Font.caption
    }
}
