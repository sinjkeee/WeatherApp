import Foundation
import RealmSwift

class Coordinate: Object {
    @objc dynamic var lat = 0.0
    @objc dynamic var lot = 0.0
}

class CurrentWeatherForRealm: Object {
    @objc dynamic var timeZone = ""
    @objc dynamic var time = 0
    @objc dynamic var temp = 0.0
    @objc dynamic var coordinate: Coordinate?
    @objc dynamic var sunrise = 0
    @objc dynamic var sunset = 0
    @objc dynamic var feelsLike = 0.0
    @objc dynamic var pressure = 0
    @objc dynamic var humidity = 0
    @objc dynamic var dewPoint = 0.0
    @objc dynamic var uvi = 0.0
    @objc dynamic var clouds = 0
    @objc dynamic var visibility = 0
    @objc dynamic var windSpeed = 0.0
    @objc dynamic var windDeg = 0
    @objc dynamic var windGust = 0.0
}
