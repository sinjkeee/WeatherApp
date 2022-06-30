import Foundation

protocol RestAPIProviderProtocol {
    func getCoordinatesByName(forCity city: String, completionHandler: @escaping (WeatherData) -> Void)
    func getWeatherForCityCoordinates(long: Double, lat: Double, withLang lang: Languages, withUnitsOfmeasurement units: Units, completionHandler: @escaping (WeatherData) -> Void)
}

class NetworkWeatherManager: RestAPIProviderProtocol {
    //MARK: - вычисляемое свойство, которое достает ключ из info.plist
    var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "apiKey") as? String else { return "" }
        return key
    }
    
    func getCoordinatesByName(forCity city: String, completionHandler: @escaping (WeatherData) -> Void) {
        let endpoint = Endpoint.geocodingURL(key: apiKey, city: city)
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = "GET"
        apiRequestAndParseJSON(urlRequest: urlRequest) { [weak self] (weatherData: [Geocoding]) in
            guard let lon = weatherData.first?.lon,
                  let lat = weatherData.first?.lat,
                  let self = self
            else { return }
            self.getWeatherForCityCoordinates(long: lon, lat: lat, withLang: .russian, withUnitsOfmeasurement: .celsius) { weatherData in
                completionHandler(weatherData)
            }
        }
    }
    
    func getWeatherForCityCoordinates(long: Double, lat: Double, withLang lang: Languages, withUnitsOfmeasurement units: Units, completionHandler: @escaping (WeatherData) -> Void) {
        let endpoint = Endpoint.currentWeather(lat: lat, lon: long, key: apiKey, lang: lang.shortName, units: units.code)
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = "GET"
        apiRequestAndParseJSON(urlRequest: urlRequest) { (weatherData: WeatherData) in
            completionHandler(weatherData)
        }
    }
    
    func apiRequestAndParseJSON<T: Codable>(urlRequest: URLRequest, completionHandler: @escaping (T) -> Void) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error)
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let currentWeather = try decoder.decode(T.self, from: data)
                    completionHandler(currentWeather)
                } catch {
                    print(error)
                }
            }
        }
        dataTask.resume()
    }
}

//MARK: - enum Languages
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

//MARK: - enum Units
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
