import Foundation

struct CurrentAndForecastWeatherData: Codable {
    var lat: Double?
    var lon: Double?
    var timeZone: String?
    var timeZoneOffset: Int?
    var current: Current?
    var minutely: [Minutely]?
    var hourly: [Current]?
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, current, minutely, hourly
        case timeZone = "timezone"
        case timeZoneOffset = "timezone_offset"
    }
}

struct Current: Codable {
    var dt: Int?
    var sunrise: Int?
    var sunset: Int?
    var temp: Double?
    var feelsLike: Double?
    var pressure: Int?
    var humidity: Int?
    var dewPoint: Double?
    var uvi: Double?
    var clouds: Int?
    var visibility: Int?
    var windSpeed: Double?
    var windDeg: Int?
    var windGust: Double?
    var weather: [Weather]?
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, uvi, clouds, visibility, weather
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
}

struct Weather: Codable {
    var id: Int?
    var main: String?
    var description: String?
    var icon: String?
}

struct Minutely: Codable {
    var dt: Int?
    var precipitation: Int?
}

struct WeatherHourly: Codable {
    var id: Int?
    var main: String?
    var description: String?
    var icon: String?
}

struct Rain: Codable {
    var oneHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}
