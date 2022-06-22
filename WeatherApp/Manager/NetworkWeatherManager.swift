import Foundation

class NetworkWeatherManager {
    // вычисляемое свойство, которое достает ключ из info.plist
    var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "apiKey") as? String else { return "" }
        return key
    }
    
    enum Languages {
        case russian
        case english
        case arabic
        case german
        case french
        case japanese
        case chinese
        case italian
        case ukrainian
        
        var shortName: String {
            switch self {
            case .russian: return "ru"
            case .english: return "en"
            case .arabic: return "ar"
            case .german: return "de"
            case .french: return "fr"
            case .japanese: return "ja"
            case .chinese: return "zh_tw"
            case .italian: return "it"
            case .ukrainian: return "ua"
            }
        }
    }
    
    enum Units {
        case celsius
        case fahrenheit
        case kelvin
        
        var code: String {
            switch self {
            case .celsius: return "metric"
            case .fahrenheit: return "imperial"
            case .kelvin: return "standard"
            }
        }
    }
    
    var completion: ((CurrentAndForecastWeatherData) -> Void)?
    
    func geocoding(forCity city: String) {
        let urlStrig = "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&appid=\(apiKey)"
        guard let url = URL(string: urlStrig) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let geocoding = try decoder.decode([Geocoding].self, from: data)
                    print(geocoding.first?.cityName ?? "nil")
                    guard let long = geocoding.first?.lon,
                          let lat = geocoding.first?.lat else { return }
                    self.currentWeather(long: long, lat: lat, withLang: .russian, withUnitsOfmeasurement: .celsius)
                } catch let error {
                    print(error)
                }
            }
        }
        dataTask.resume()
    }
    
    func currentWeather(long: Double, lat: Double, withLang lang: Languages, withUnitsOfmeasurement units: Units) {
        let urlStrig = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&exclude=daily&appid=\(apiKey)&lang=\(lang.shortName)&units=\(units.code)"
        guard let url = URL(string: urlStrig) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            if let error = error {
                print(error)
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let currentWeather = try decoder.decode(CurrentAndForecastWeatherData.self, from: data)
                    print(currentWeather.current?.feelsLike ?? "some error")
                    self?.completion?(currentWeather)
                } catch let error {
                    print(error)
                }
            }
        }
        dataTask.resume()
    }
}
