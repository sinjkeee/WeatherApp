import Foundation

protocol RestAPIProviderProtocol {
    func getCoordinatesByName(forCity city: String, completionHandler: @escaping (Result<[Geocoding], Error>) -> Void)
    func getWeatherForCityCoordinates(long: Double, lat: Double, withLang lang: Languages, withUnitsOfmeasurement units: Units, completionHandler: @escaping (Result<WeatherData, Error>) -> Void)
}

class NetworkWeatherManager: RestAPIProviderProtocol {
    //MARK: - вычисляемое свойство, которое достает ключ из info.plist
    var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "apiKey") as? String else { return "" }
        return key
    }
    
    func getCoordinatesByName(forCity city: String, completionHandler: @escaping (Result<[Geocoding], Error>) -> Void) {
        let newCity = city.trimmingCharacters(in: .whitespaces).split(separator: " ").joined(separator: "%20")
        guard let name = newCity.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        let endpoint = Endpoint.geocodingURL(key: apiKey, city: name)
        guard let url = endpoint.url else {
            completionHandler(.failure(Error.self as! Error))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        apiRequestAndParseJSON(urlRequest: urlRequest) { (result: Result<[Geocoding], Error>) in
            completionHandler(result)
        }
    }
    
    func getWeatherForCityCoordinates(long: Double, lat: Double, withLang lang: Languages, withUnitsOfmeasurement units: Units, completionHandler: @escaping (Result<WeatherData, Error>) -> Void) {
        let endpoint = Endpoint.currentWeather(lat: lat, lon: long, key: apiKey, lang: lang.shortName, units: units.code)
        guard let url = endpoint.url else {
            completionHandler(.failure(Error.self as! Error))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        apiRequestAndParseJSON(urlRequest: urlRequest) { (result: Result<WeatherData, Error>) in
            completionHandler(result)
        }
    }
    
    func apiRequestAndParseJSON<T: Codable>(urlRequest: URLRequest, completionHandler: @escaping (Result<T, Error>) -> Void) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let currentWeather = try decoder.decode(T.self, from: data)
                    completionHandler(.success(currentWeather))
                } catch {
                    completionHandler(.failure(error))
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
        case .english: return "en Languages".localized()
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
