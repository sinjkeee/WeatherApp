import Foundation
import RealmSwift

protocol RealmManagerProtocol {
    func savaData(data: WeatherData)
    func loadData() -> [CurrentWeatherForRealm]
}

class RealmManager: RealmManagerProtocol {
    
    var realm: Realm!
    
    init() {
        var configuration = Realm.Configuration()
        configuration.deleteRealmIfMigrationNeeded = true
        do {
            realm = try Realm(configuration: configuration)
        } catch {
            print(error)
        }
    }
    
    func savaData(data: WeatherData) {
        
        let coordinateForRealm = Coordinate()
        let currentWeatherForRealm = CurrentWeatherForRealm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        guard let temp = data.current?.temp,
              let time = data.current?.dt,
              let long = data.lon,
              let lat = data.lat,
              let sunrise = data.current?.sunrise,
              let sunset = data.current?.sunset,
              let feelsLike = data.current?.feelsLike,
              let pressure = data.current?.pressure,
              let humidity = data.current?.humidity,
              let dewPoint = data.current?.dewPoint,
              let uvi = data.current?.uvi,
              let clouds = data.current?.clouds,
              let visibility = data.current?.visibility,
              let windSpeed = data.current?.windSpeed,
              let windDeg = data.current?.windDeg,
              let windGust = data.current?.windGust,
              let timeZone = data.timeZone
        else { return }
        
        coordinateForRealm.lat = lat
        coordinateForRealm.lot = long
        currentWeatherForRealm.coordinate = coordinateForRealm
        currentWeatherForRealm.temp = temp
        currentWeatherForRealm.time = time
        currentWeatherForRealm.sunrise = sunrise
        currentWeatherForRealm.sunset = sunset
        currentWeatherForRealm.feelsLike = feelsLike
        currentWeatherForRealm.pressure = pressure
        currentWeatherForRealm.humidity = humidity
        currentWeatherForRealm.dewPoint = dewPoint
        currentWeatherForRealm.uvi = uvi
        currentWeatherForRealm.clouds = clouds
        currentWeatherForRealm.visibility = visibility
        currentWeatherForRealm.windSpeed = windSpeed
        currentWeatherForRealm.windDeg = windDeg
        currentWeatherForRealm.windGust = windGust
        currentWeatherForRealm.timeZone = timeZone
        
        do {
            try realm.write({
                realm.add(currentWeatherForRealm)
            })
        } catch let error {
            print(error)
        }
        NotificationCenter.default.post(name: .databaseUpdated, object: nil, userInfo: nil)
    }
    
    func loadData() -> [CurrentWeatherForRealm] {
        var array: [CurrentWeatherForRealm]
        array = realm.objects(CurrentWeatherForRealm.self).map{$0}.reversed()
        return array
    }
}
