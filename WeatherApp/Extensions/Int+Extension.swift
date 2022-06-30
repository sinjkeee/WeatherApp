import Foundation
import UIKit

extension Int {
    func changeDate(dateFormat: DateFormat) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = dateFormat.getString
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}

enum DateFormat: String {
    case hours
    case days
    case fullTime
    
    var getString: String {
        switch self {
        case .hours: return "HH"
        case .days: return "HH MMMM yyyy"
        case .fullTime: return "EEEE, d MMMM yyyy HH:mm:ss"
        }
    }
}