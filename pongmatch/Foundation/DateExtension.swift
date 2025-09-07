import Foundation

extension Date {
    var display: String {
        DateFormatter.localizedString(from: self, dateStyle: .short,timeStyle: .medium)
    }
    
    var displayForHumans: String {
        let secondsAgo = Int(Date().timeIntervalSince(self))

        if secondsAgo < 60 {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo < 3600 {
            let minutes = secondsAgo / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if secondsAgo < 86400 {
            let hours = secondsAgo / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if secondsAgo < 604800 { // less than 7 days
            let days = secondsAgo / 86400
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
        return display
    }
}
