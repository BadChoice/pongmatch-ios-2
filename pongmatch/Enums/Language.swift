import Foundation

enum Language : String, Codable, CaseIterable, CustomStringConvertible {
    case english = "en"
    case spanish = "es"
    case catalan = "ca"
    case french  = "fr"
    case german  = "de"
    case italian  = "it"
    
    var description: String {
        switch self {
        case .english: "English"
        case .spanish: "Spanish"
        case .catalan: "Catala"
        case .french:  "French"
        case .german:  "German"
        case .italian: "Italian"
        }
    }
}
