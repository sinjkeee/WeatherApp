import Foundation

struct NetworkWeatherManager {
    // вычисляемое свойство, которое достает ключ из info.plist
    var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "apiKey") as? String else { return "" }
        return key
    }
    
    func fetchCurrentWeather(forCity city: String) {
        // url откуда к нам приходит json
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)"
        // получаем URL со строки urlString
        guard let url = URL(string: urlString) else { return }
        // создаем запрос по нашему url
        var urlRequest = URLRequest(url: url)
        // тип запроса
        urlRequest.httpMethod = "GET"
        // создаем сессию
        let session = URLSession(configuration: .default)
        // создаем таск непосредственно для запроса на сервер
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error { // если будет ошибка, мы ее печатаем и дальше не идем
                print("ERROR!!! – \(error)")
                return
            }
            
            if let data = data { // проверяем данные, что они не nil
                self.parseJSON(withData: data) // если данные есть, передаем их в метод parseJSON
            }
        }
        dataTask.resume()
    }
    
    // метод parseJSON декодирует json в структуры, которые мы определили для этого
    func parseJSON(withData data: Data) { 
        let decoder = JSONDecoder() // создаем декодер
        do { // наш декодер возвращает объект currentWeatherData
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
            print(currentWeatherData.name ?? "") // пока просто печатаем в консоль
        } catch let error {
            print(error)
        }
    }
    
}
