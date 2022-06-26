import Foundation


extension URL {
    static func makeEndpointWithWeather(_ endpoint: String) -> URL {
        URL(string: "https://api.openweathermap.org/\(endpoint)")!
    }
    static func makeEndpointWithIcon(_ endpoint: String) -> URL {
        URL(string: "https://openweathermap.org/\(endpoint)")!
    }
}

enum Endpoint {
    case geocodingURL(key: String, city: String)
    case getIcon(icon: String)
    case currentWeather(lat: Double, lon: Double, key: String, lang: String, units: String)
}

extension Endpoint {
    var url: URL {
        switch self {
        case .geocodingURL(let key, let city):
            return .makeEndpointWithWeather("geo/1.0/direct?q=\(city)&appid=\(key)")
        case .getIcon(let icon):
            return .makeEndpointWithIcon("img/wn/\(icon)@2x.png")
        case .currentWeather(let lat, let lon, let key, let lang, let units):
            return .makeEndpointWithWeather("data/2.5/onecall?lat=\(lat)&lon=\(lon)&appid=\(key)&lang=\(lang)&units=\(units)")
        }
    }
}
