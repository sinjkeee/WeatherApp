import UIKit
import CoreLocation

class TabBarController: UITabBarController {
    //MARK: - var/let
    private var citiesDict = [String: WeatherData]()
    private var weatherData = [String: (WeatherData, [Geocoding])]()
    private var geocoding = [Geocoding]()
    private var weatherArray = [WeatherData]()
    private let notificationCenter = UNUserNotificationCenter.current()
    private var networkWeatherManager: RestAPIProviderProtocol = NetworkWeatherManager()
    private var units: String = ""
    private var citiesArray: [String: [Double]]?
    private var coordinate: CLLocationCoordinate2D?
    private var reverseGeocoding: [ReverseGeocoding]?
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        return lm
    }()
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "my queue", qos: .userInteractive, attributes: .concurrent)
    var realPageController = PageViewController()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeatherData), name: .updateMainInterface, object: nil)
        
        guard let second = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }
        guard let settingsNavi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsNavi") as? UINavigationController else { return }
        guard let pageController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as? PageViewController else { return }
        realPageController = pageController
        
        updateWeatherData()
        
        self.tabBar.backgroundColor = UIColor.white
        self.setViewControllers([pageController, second, settingsNavi], animated: true)
        pageController.tabBarItem.title = "Main"
        pageController.tabBarItem.image = UIImage(systemName: "thermometer")
        second.tabBarItem.title = "Map".localized()
        second.tabBarItem.image = UIImage(systemName: "globe.europe.africa")
        settingsNavi.tabBarItem.title = "Settings".localized()
        settingsNavi.tabBarItem.image = UIImage(systemName: "gearshape")
    }
    //MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods
    @objc private func updateWeatherData() {
        
        self.weatherArray.removeAll()
        
        citiesArray = UserDefaults.standard.value(forKey: "cities2") as? [String: [Double]]
        units = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true ? "metric" : "imperial"
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            group.enter()
            locationManager.requestLocation()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            group.enter()
            locationManager.requestLocation()
        }
        
        if citiesArray != nil {
            queue.async(group: group) {
                for city in self.citiesArray! {
                    self.group.enter()
                    self.getWeatherForCities(cities: city.key) { (geodata, weather, name) in
                        var finalWeather = weather
                        finalWeather.name = self.getCityName(with: geodata)
                        self.weatherArray.append(finalWeather)
                        
                        self.group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.realPageController.updateViewControllers(with: self.weatherArray)
        }
    }
    
    private func getWeatherForCities(cities: String, completionHandler: @escaping ([Geocoding], WeatherData, String) -> Void) {
        self.networkWeatherManager.getCoordinatesByName(forCity: cities) { [weak self] (result: Result<[Geocoding], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let geodata):
                self.geocoding = geodata
                guard let lon = geodata.first?.lon, let lat = geodata.first?.lat else { return }
                self.networkWeatherManager.getWeatherForCityCoordinates(long: lon, lat: lat, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                    switch result {
                    case .success(let weather):
                        completionHandler(geodata, weather, cities)
                    case .failure(let failure):
                        print(failure.localizedDescription)
                        self.group.leave()
                    }
                }
            case .failure(let failure):
                print(failure.localizedDescription)
                self.group.leave()
            }
        }
    }
    
    private func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okeyButton = UIAlertAction(title: "Ok".localized(), style: .default, handler: nil)
        alertController.addAction(okeyButton)
        present(alertController, animated: true)
    }
    
    private func getCityName(with geocoding: [Geocoding]) -> String {
        guard let name = geocoding.first?.cityName,
              let ruName = geocoding.first?.localNames?.ru,
              let country = geocoding.first?.country else  { fatalError() }
        let localeNames = ["ru": ruName, "en": name]
        guard let finalName = localeNames["key".localized()] else { fatalError() }
        return "\(finalName), \(country)"
    }
    
    private func weatherCheck(hourlyWeather: [HourlyWeatherData]?) {
        guard let hourlyWeather = hourlyWeather else { return }
        var index = 0
        guard let notifications = UserDefaults.standard.value(forKey: "notifications") as? [Bool] else { return }
        for hour in hourlyWeather {
            guard let id = hour.weather?.first?.id, let time = hour.dt else { return }
            //Если плохая погода впервые или перерыв между уведомлениями больше 3х часов, отправляем новое уведомление
            if index == 0 || index > 3 {
                switch id {
                case 200...232:
                    if !notifications.isEmpty && notifications[0] {
                        setLocalNotification(body: "There will be a storm soon!".localized(), title: "Attention!".localized(), dateComponents: getDateComponentsFrom(date: time))
                    } else if notifications.isEmpty {
                        setLocalNotification(body: "There will be a storm soon!".localized(), title: "Attention!".localized(), dateComponents: getDateComponentsFrom(date: time))
                    }
                    index = 1
                case 500...531:
                    if !notifications.isEmpty && notifications[1] {
                        setLocalNotification(body: "There will be a rain soon!".localized(), title: "Attention!".localized(), dateComponents: getDateComponentsFrom(date: time))
                    } else if notifications.isEmpty {
                        setLocalNotification(body: "There will be a rain soon!".localized(), title: "Attention!".localized(), dateComponents: getDateComponentsFrom(date: time))
                    }
                    index = 1
                case 600...622:
                    if !notifications.isEmpty && notifications[2] {
                        setLocalNotification(body: "There will be a snow soon!".localized(), title: "Attention!".localized(), dateComponents: getDateComponentsFrom(date: time))
                    } else if notifications.isEmpty {
                        setLocalNotification(body: "There will be a snow soon!".localized(), title: "Attention!".localized(), dateComponents: getDateComponentsFrom(date: time))
                    }
                    index = 1
                default: break
                }
            }
            index += 1
        }
    }
    
    private func getDateComponentsFrom(date: Int) -> DateComponents {
        let calendar = Calendar.current
        let newDate = Date(timeIntervalSince1970: TimeInterval(date))
        var newDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        guard let minutes = newDateComponents.minute else { fatalError() }
        newDateComponents.minute = minutes - 30
        return newDateComponents
    }
    
    private func setLocalNotification(body: String, title: String, dateComponents: DateComponents) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] isAutorized, error in
            guard let self = self else { return }
            if isAutorized {
                let content = UNMutableNotificationContent()
                content.body = body
                content.title = title
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let identifier = "identifier"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                self.notificationCenter.add(request) { error in
                    if let error = error {
                        print(error)
                    }
                }
            } else if let error = error {
                print(error)
            }
        }
    }
    
    private func removeAllNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

//MARK: - CLLocationManagerDelegate
extension TabBarController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location?.coordinate else { return }
        self.coordinate = location
        
        
        var cityName = "Local"
        self.group.enter()
        self.networkWeatherManager.getCityNameForCoordinates(lon: location.longitude, lat: location.latitude) { [weak self] (result: Result<[ReverseGeocoding], Error>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                }
            case .success(let reverseGeo):
                self.reverseGeocoding = reverseGeo
                DispatchQueue.main.async {
                    guard let name = reverseGeo.first?.name else { return }
                    let ruName = reverseGeo.first?.localNames?.ru ?? name
                    let enName = reverseGeo.first?.localNames?.en ?? name
                    let nameDict = ["ru": ruName, "en": enName]
                    guard let finalName = nameDict["key".localized()] else { return }
                    self.title = finalName
                    cityName = finalName
                }
            }
        }
        
        self.networkWeatherManager.getWeatherForCityCoordinates(long: location.longitude, lat: location.latitude, language: "languages".localized(), units: self.units) { [weak self] (result: Result<WeatherData, Error>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                }
            case .success(let weatherData):
                
                var weather = weatherData
                weather.name = cityName
                self.weatherArray.append(weather)
                self.group.leave()
                self.group.leave()
                DispatchQueue.main.async {
                    self.removeAllNotification()
                    self.weatherCheck(hourlyWeather: weather.hourly)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        } else if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            
        } else if manager.authorizationStatus == .notDetermined {
            locationManager.requestLocation()
        }
    }
}
