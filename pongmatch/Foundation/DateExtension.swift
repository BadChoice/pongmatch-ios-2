import Foundation

extension Date {
    var display: String {
        DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }
    
    var displayForHumans: String {
        let interval = Int(self.timeIntervalSinceNow) // positive = future, negative = past
        let seconds = abs(interval)

        let suffix = interval < 0 ? "ago" : "from now"

        if seconds < 60 {
            return "\(seconds) second\(seconds == 1 ? "" : "s") \(suffix)"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s") \(suffix)"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s") \(suffix)"
        } else if seconds < 604800 { // less than 7 days
            let days = seconds / 86400
            return "\(days) day\(days == 1 ? "" : "s") \(suffix)"
        }
        
        return display
    }
}
