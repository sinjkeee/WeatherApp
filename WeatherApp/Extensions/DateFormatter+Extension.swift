import Foundation

extension DateFormatter {
    func daysFormatt(dt: Int, isTime: Bool) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let dateFormatter = DateFormatter()
        if isTime {
            dateFormatter.timeStyle = DateFormatter.Style.short
        } else {
            dateFormatter.dateStyle = DateFormatter.Style.medium
        }
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}
