import Foundation

enum Endpoint {
    case geocodingURL(key: String, city: String)
    case getIcon(icon: String)
    case currentWeather(lat: Double, lon: Double, key: String, lang: String, units: String)
}

extension Endpoint {
    var baseURLForWeather: String {
        return "https://api.openweathermap.org/"
    }
    
    var baseURLForIcon: String {
        return "https://openweathermap.org/"
    }
    
    var url: URL? {
        switch self {
        case .geocodingURL(let key, let city):
            if let url = URL(string: baseURLForWeather.appending("geo/1.0/direct?q=\(city)&appid=\(key)")) {
                return url
            }
//            fatalError()
            return nil
        case .getIcon(let icon):
            if let url = URL(string: baseURLForIcon.appending("img/wn/\(icon)@2x.png")) {
                return url
            }
//            fatalError()
            return nil
        case .currentWeather(let lat, let lon, let key, let lang, let units):
            if let url = URL(string: baseURLForWeather.appending("data/2.5/onecall?lat=\(lat)&lon=\(lon)&appid=\(key)&lang=\(lang)&units=\(units)")) {
                return url
            }
//            fatalError()
            return nil
        }
    }
}
