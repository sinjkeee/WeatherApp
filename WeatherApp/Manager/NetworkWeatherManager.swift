import Foundation

protocol RestAPIProviderProtocol {
    func getCoordinatesByName(forCity city: String, completionHandler: @escaping (Result<[Geocoding], Error>) -> Void)
    func getWeatherForCityCoordinates(long: Double, lat: Double, language: String, units: String, completionHandler: @escaping (Result<WeatherData, Error>) -> Void)
    func getCityNameForCoordinates(lon: Double, lat: Double, completionHandler: @escaping (Result<[ReverseGeocoding], Error>) -> Void)
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
    
    func getWeatherForCityCoordinates(long: Double, lat: Double, language: String, units: String, completionHandler: @escaping (Result<WeatherData, Error>) -> Void) {
        let endpoint = Endpoint.currentWeather(lat: lat, lon: long, key: apiKey, lang: language, units: units)
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
    
    func getCityNameForCoordinates(lon: Double, lat: Double, completionHandler: @escaping (Result<[ReverseGeocoding], Error>) -> Void) {
        let endpoint = Endpoint.getCityName(lon: lon, lat: lat, key: apiKey)
        guard let url = endpoint.url else {
            completionHandler(.failure(Error.self as! Error))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        apiRequestAndParseJSON(urlRequest: urlRequest) { (result: Result<[ReverseGeocoding], Error>) in
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
