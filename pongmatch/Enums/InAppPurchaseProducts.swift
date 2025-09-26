
enum InAppPurchaseProducts : String, CustomStringConvertible {
    case smallCoffee = "io.codepassion.pongmatch.inapp_purchase_small_coffee"
    case mediuCoffee = "io.codepassion.pongmatch.inapp_purchase_medium_coffee"
    case largeCoffee = "io.codepassion.pongmatch.inapp_purchase_large_coffee"
    case extraLargeCoffee = "io.codepassion.pongmatch.inapp_purchase_extra_large_coffee"
    
    var description : String {
        switch self {
        case .smallCoffee: "Small Coffee"
        case .mediuCoffee: "Medium Coffee"
        case .largeCoffee: "Large Coffee"
        case .extraLargeCoffee: "Extra Large Coffee"
        }
    }
}
