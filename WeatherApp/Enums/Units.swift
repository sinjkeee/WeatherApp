import Foundation

enum Units {
    case metric
    case imperial
    
    var distanceString: String {
        switch self {
        case .metric: return "km/h".localized()
        case .imperial: return "ml/h".localized()
        }
    }
    
    var temperatureString: String {
        switch self {
        case .metric: return "˚C"
        case .imperial: return "˚F"
        }
    }
}
