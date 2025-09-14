import Foundation

enum Language : String, Codable, CaseIterable, CustomStringConvertible {
    case english = "en"
    case spanish = "es"
    case catalan = "ca"
    case french  = "fr"
    case german  = "de"
    
    var description: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .catalan: return "Catala"
        case .french:  return "French"
        case .german:  return "German"
        }
    }
}
