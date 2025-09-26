import SwiftUI

enum InAppPurchaseProducts: String, CaseIterable, CustomStringConvertible {
    case smallCoffee = "io.codepassion.pongmatch.inapp_purchase_small_coffee"
    case mediumCoffee = "io.codepassion.pongmatch.inapp_purchase_medium_coffee"
    case largeCoffee = "io.codepassion.pongmatch.inapp_purchase_large_coffee"
    case extraLargeCoffee = "io.codepassion.pongmatch.inapp_purchase_extra_large_coffee"

    var description: String {
        switch self {
        case .smallCoffee: "Small"
        case .mediumCoffee: "Medium"
        case .largeCoffee: "Large"
        case .extraLargeCoffee: "Extra Large"
        }
    }

    var iconScale: CGFloat {
        switch self {
        case .smallCoffee: 1.0
        case .mediumCoffee: 1.15
        case .largeCoffee: 1.3
        case .extraLargeCoffee: 1.45
        }
    }
}
