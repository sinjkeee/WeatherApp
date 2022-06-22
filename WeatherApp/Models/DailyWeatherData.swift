import Foundation

struct DailyWeatherData: Codable {
    var lat: Double?
    var lon: Double?
    var timeZone: String?
    var timeZoneOffset: Int?
    var daily: [Daily]?
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, daily
        case timeZone = "timezone"
        case timeZoneOffset = "timezone_offset"
    }
}

struct Daily: Codable {
    var dt: Int?
    var sunrise: Int?
    var sunset: Int?
    var moonrise: Int?
    var moonset: Int?
    var moon_phase: Double?
    var temp: Temp?
    var feelsLike: FeelsLike?
    var pressure: Int?
    var humidity: Int?
    var dewPoint: Double?
    var windSpeed: Double?
    var windDeg: Int?
    var windGust: Double?
    var weather: [WeatherDaily]?
    var clouds: Int?
    var pop: Int?
    var rain: Double?
    var uvi: Double?
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, moonrise, moonset, temp, pressure, humidity, weather, clouds, pop, rain, uvi
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
}


struct Temp: Codable {
    var day: Double?
    var min: Double?
    var max: Double?
    var night: Double?
    var eve: Double?
    var morn: Double?
}

struct FeelsLike: Codable {
    var day: Double?
    var night: Double?
    var eve: Double?
    var morn: Double?
}

struct WeatherDaily: Codable {
    var id: Int?
    var main: String?
    var description: String?
    var icon: String?
}
