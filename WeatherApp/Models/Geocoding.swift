import Foundation

struct Geocoding: Codable {
    var cityName: String?
    var lat: Double?
    var lon: Double?
    var country: String?
    var localNames: LocalNames?
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, country
        case cityName = "name"
        case localNames = "local_names"
    }
}

struct LocalNames: Codable {
    var ru: String?
}
