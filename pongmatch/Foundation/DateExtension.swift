import Foundation

extension Date {
    var display: String {
        DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }

    var compactDisplay: String {
        // If the date is in the current year, omit the year; otherwise include it.
        let calendar = Calendar.current
        let nowYear = calendar.component(.year, from: Date())
        let targetYear = calendar.component(.year, from: self)

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.doesRelativeDateFormatting = false

        if nowYear == targetYear {
            // Example: "Sep 21" (locale-aware; adjust pattern if you prefer a different style)
            // Using "MMM d" keeps it short, similar to .medium without the year.
            formatter.setLocalizedDateFormatFromTemplate("MMMd")
        } else {
            // Include the year; similar to .medium date style with year.
            formatter.setLocalizedDateFormatFromTemplate("MMMdyyyy")
        }

        return formatter.string(from: self)
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
    
    var toISOString: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime] // Gives 2025-09-11T13:23:15Z or +00:00
        return formatter.string(from: Date())
    }
}
