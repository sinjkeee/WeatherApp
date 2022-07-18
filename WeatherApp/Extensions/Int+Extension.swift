import Foundation
import UIKit

extension Int {
    func changeDate(dateFormat: DateFormat) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = dateFormat.getString
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}

enum DateFormat: String {
    case hours
    case days
    case fullTime
    case weekday
    
    var getString: String {
        switch self {
        case .hours:
            guard let value = UserDefaults.standard.value(forKey: "timeSetting") as? Bool else { return "HH" }
            if value {
                return "h a"
            } else {
                return "HH"
            }
        case .days: return "HH MMMM yyyy"
        case .fullTime: return "EEEE, d MMMM yyyy HH:mm:ss"
        case .weekday: return "EEEE"
        }
    }
}
