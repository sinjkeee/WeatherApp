import Foundation

struct CurrentWeatherData: Codable {
    let coordinates: Coordinates?
    let weather: [Weather]?
    let base: String?
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let timeOfData: Int?
    let sys: Sys?
    let timeZone: Int?
    let id: Int?
    let name: String?
    let cod: Int?
    
    enum CodingKeys: String, CodingKey {
        case weather, base, main, visibility, wind, clouds, id, name, sys, cod
        case timeZone = "timezone"
        case coordinates = "coord"
        case timeOfData = "dt"
    }
}

struct Coordinates: Codable {
    let lon: Double?
    let lat: Double?
}

struct Weather: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}

struct Main: Codable {
    let temp: Double?
    let feelsLike: Double?
    let tempMin: Double?
    let tempMax: Double?
    let pressure: Int?
    let humidity: Int?
    let seaLevel: Int?
    let groundLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
    }
}

struct Wind: Codable {
    let speed: Double?
    let deg: Double?
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int?
}

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}
