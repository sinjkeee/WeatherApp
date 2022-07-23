import UIKit
import RealmSwift
import CoreLocation

class MainViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var findCityButton: UIButton!
    
    //MARK: - let/var
    private let refresh = UIRefreshControl()
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        return lm
    }()
    private var realmManager: RealmManagerProtocol = RealmManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    var geoData: [Geocoding]?
    private var coordinate: CLLocationCoordinate2D?
    private var currentWeather: WeatherData?
    private var hourlyWeather: [HourlyWeatherData]?
    private var dailyWeather: [DailyWeatherData]?
    private var reverseGeocoding: [ReverseGeocoding]?
    var networkWeatherManager: RestAPIProviderProtocol = NetworkWeatherManager()
    var units: String = ""
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.units = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true ? "metric" : "imperial"
        self.geoData = nil
        self.findCityButton.tintColor = .systemCyan
        self.getLocationButton.tintColor = .systemCyan
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMainInterface), name: .updateMainInterface, object: nil)
        
        tableView.register(UINib(nibName: "CellWithCollectionView", bundle: nil), forCellReuseIdentifier: "CellWithCollectionView")
        tableView.register(UINib(nibName: "DailyWeatherCell", bundle: nil), forCellReuseIdentifier: "DailyWeatherCell")
        tableView.register(UINib(nibName: "CurrentWeatherCell", bundle: nil), forCellReuseIdentifier: "CurrentWeatherCell")
        
        createAndShowBlurEffectWithActivityIndicator()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        self.addGradient()
        
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .notDetermined {
            let lastCity = UserDefaults.standard.value(forKey: "city") != nil ? UserDefaults.standard.value(forKey: "city") as! String : "Kaliningrad"
            self.networkWeatherManager.getCoordinatesByName(forCity: lastCity) { [weak self] (result: Result<[Geocoding], Error>) in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.hideBlurView()
                        self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                    }
                case .success(let geocoding):
                    self.geoData = geocoding
                    guard let longitude = geocoding.first?.lon, let latitude = geocoding.first?.lat else { return }
                    self.networkWeatherManager.getWeatherForCityCoordinates(long: longitude, lat: latitude, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                        switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async {
                                self.hideBlurView()
                                self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                            }
                        case .success(let weatherData):
                            self.combiningMethods(weatherData: weatherData)
                            DispatchQueue.main.async {
                                self.findCityButton.tintColor = .systemPink
                            }
                        }
                    }
                }
            }
        } else if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            if UserDefaults.standard.value(forKey: "city") != nil {
                let lastCity = UserDefaults.standard.value(forKey: "city") as! String
                self.networkWeatherManager.getCoordinatesByName(forCity: lastCity) { [weak self] (result: Result<[Geocoding], Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            self.hideBlurView()
                            self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                        }
                    case .success(let geocoding):
                        self.geoData = geocoding
                        guard let longitude = geocoding.first?.lon, let latitude = geocoding.first?.lat else { return }
                        self.networkWeatherManager.getWeatherForCityCoordinates(long: longitude, lat: latitude, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                            switch result {
                            case .failure(let error):
                                print(error.localizedDescription)
                                DispatchQueue.main.async {
                                    self.hideBlurView()
                                    self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                                }
                            case .success(let weatherData):
                                self.combiningMethods(weatherData: weatherData)
                                DispatchQueue.main.async {
                                    self.findCityButton.tintColor = .systemPink
                                }
                            }
                        }
                    }
                }
            } else if UserDefaults.standard.value(forKey: "location") != nil {
                locationManager.requestLocation()
                self.geoData = nil
            }
        }
    }
    //MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - @IBAction
    @IBAction func listOfCitiesPressed(_ sender: UIBarButtonItem) {
        guard let citiesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CitiesNaviController") as? UINavigationController else { return }
        present(citiesViewController, animated: true)
    }
    
    @IBAction func findCityPressed(_ sender: UIButton) {
        presentSearchAlertController(withTitle: "Enter city name".localized(), message: nil, style: .alert)
    }
    
    @IBAction func getLocationPressed(_ sender: UIButton) {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    @IBAction func refreshTableView() {
        if geoData != nil {
            self.createAndShowBlurEffectWithActivityIndicator()
            guard let cityName = geoData?.first?.cityName else { return }
            self.networkWeatherManager.getCoordinatesByName(forCity: cityName) { [weak self] (result: Result<[Geocoding], Error>) in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.hideBlurView()
                        self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                    }
                case .success(let geocoding):
                    self.geoData = geocoding
                    guard let longitude = geocoding.first?.lon, let latitude = geocoding.first?.lat else { return }
                    self.networkWeatherManager.getWeatherForCityCoordinates(long: longitude, lat: latitude, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                        switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async {
                                self.hideBlurView()
                                self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                            }
                        case .success(let weatherData):
                            self.combiningMethods(weatherData: weatherData)
                        }
                    }
                }
            }
        } else {
            self.createAndShowBlurEffectWithActivityIndicator()
            locationManager.requestLocation()
            guard let coordinate = coordinate else { return }
            self.networkWeatherManager.getCityNameForCoordinates(lon: coordinate.longitude, lat: coordinate.latitude) { [weak self] (result: Result<[ReverseGeocoding], Error>) in
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
                    }
                }
            }
            self.networkWeatherManager.getWeatherForCityCoordinates(long: coordinate.longitude, lat: coordinate.latitude, language: "languages".localized(), units: self.units) { [weak self] (result: Result<WeatherData, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let weatherData):
                    self.combiningMethods(weatherData: weatherData)
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.hideBlurView()
                        self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                    }
                }
            }
        }
        refresh.endRefreshing()
    }
    
    @IBAction func updateMainInterface() {
        self.units = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true ? "metric" : "imperial"
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .notDetermined {
            let lastCity = UserDefaults.standard.value(forKey: "city") as? String ?? "Kaliningrad"
            self.networkWeatherManager.getCoordinatesByName(forCity: lastCity) { [weak self] (result: Result<[Geocoding], Error>) in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                    }
                case .success(let geocoding):
                    self.geoData = geocoding
                    guard let longitude = geocoding.first?.lon, let latitude = geocoding.first?.lat else { return }
                    self.networkWeatherManager.getWeatherForCityCoordinates(long: longitude, lat: latitude, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                        switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                            }
                        case .success(let weatherData):
                            self.combiningMethods(weatherData: weatherData)
                            DispatchQueue.main.async {
                                self.findCityButton.tintColor = .systemPink
                            }
                        }
                    }
                }
            }
        } else if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            if let lastCity = UserDefaults.standard.value(forKey: "city") as? String {
                self.networkWeatherManager.getCoordinatesByName(forCity: lastCity) { [weak self] (result: Result<[Geocoding], Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                        }
                    case .success(let geocoding):
                        self.geoData = geocoding
                        guard let longitude = geocoding.first?.lon, let latitude = geocoding.first?.lat else { return }
                        self.networkWeatherManager.getWeatherForCityCoordinates(long: longitude, lat: latitude, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                            switch result {
                            case .failure(let error):
                                print(error.localizedDescription)
                                DispatchQueue.main.async {
                                    self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                                }
                            case .success(let weatherData):
                                self.combiningMethods(weatherData: weatherData)
                                DispatchQueue.main.async {
                                    self.findCityButton.tintColor = .systemPink
                                }
                            }
                        }
                    }
                }
            } else if UserDefaults.standard.value(forKey: "location") != nil {
                locationManager.requestLocation()
                self.geoData = nil
            }
        }
    }
    
    //MARK: - Methods
    func combiningMethods(weatherData: WeatherData) {
        self.saveCurrentData(weatherData: weatherData)
        DispatchQueue.main.async {
            self.realmManager.savaData(data: weatherData, isMap: false)
            self.updateInterface(hourlyWeather: self.hourlyWeather)
        }
    }
    
    private func saveCurrentData(weatherData: WeatherData) {
        self.currentWeather = weatherData
        self.hourlyWeather = weatherData.hourly
        self.dailyWeather = weatherData.daily
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
    
    private func updateInterface(hourlyWeather: [HourlyWeatherData]?) {
        if self.geoData != nil {
            guard let name = self.geoData?.first?.cityName,
                  let ruName = self.geoData?.first?.localNames?.ru,
                  let country = self.geoData?.first?.country else  { return }
            let localeNames = ["ru": ruName, "en": name]
            guard let finalName = localeNames["key".localized()] else { return }
            self.title = "\(finalName), \(country)"
        }
        self.tableView.reloadData()
        self.removeAllNotification()
        self.weatherCheck(hourlyWeather: hourlyWeather)
        self.hideBlurView()
    }
}

//MARK: - extension TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return dailyWeather?.count ?? 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Current weather".localized()
        } else if section == 1 {
            return "Hourly forecasts".localized()
        } else {
            return "Daily forecasts".localized()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyWeatherCell") as? DailyWeatherCell else { return UITableViewCell() }
        guard let hourlyCell = tableView.dequeueReusableCell(withIdentifier: "CellWithCollectionView") as? CellWithCollectionView else { return UITableViewCell() }
        guard let currentWeatherCell = tableView.dequeueReusableCell(withIdentifier: "CurrentWeatherCell") as? CurrentWeatherCell else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            if let weather = currentWeather {
                currentWeatherCell.configureCurrentWeatherCell(data: weather)
            }
            return currentWeatherCell
        } else if indexPath.section == 1 {
            if let hourlyWeatherData = hourlyWeather {
                hourlyCell.configure(hourlyWeatherData)
            }
            return hourlyCell
        } else {
            if let daily = dailyWeather {
                cell.configureDailyCell(data: daily[indexPath.row], isFirst: indexPath.row == 0)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        } else if indexPath.section == 1 {
            return 100
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
}

//MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        self.coordinate = location
        
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
                self.combiningMethods(weatherData: weatherData)
                self.geoData = nil
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: "city")
                    UserDefaults.standard.set(true, forKey: "location")
                    self.findCityButton.tintColor = .systemCyan
                    self.getLocationButton.tintColor = .systemPink
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            if UserDefaults.standard.value(forKey: "city") != nil {
                self.findCityButton.tintColor = .systemPink
                self.getLocationButton.tintColor = .systemCyan
                self.getLocationButton.isEnabled = true
            } else if UserDefaults.standard.value(forKey: "location") != nil {
                locationManager.requestLocation()
                self.getLocationButton.isEnabled = true
            } else {
                locationManager.requestLocation()
                self.getLocationButton.isEnabled = true
            }
        } else if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            self.getLocationButton.isEnabled = false
            UserDefaults.standard.removeObject(forKey: "location")
        } else if manager.authorizationStatus == .notDetermined {
            self.getLocationButton.isEnabled = true
        }
    }
}
