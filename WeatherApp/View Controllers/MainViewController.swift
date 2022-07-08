import UIKit
import RealmSwift
import CoreLocation

class MainViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - let/var
    let refresh = UIRefreshControl()
    let locationManager = CLLocationManager()
    var realmManager: RealmManagerProtocol = RealmManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var geoData: [Geocoding]?
    var coordinate: CLLocationCoordinate2D?
    var currentWeather: WeatherData?
    var hourlyWeather: [HourlyWeatherData]?
    var dailyWeather: [DailyWeatherData]?
    var networkWeatherManager: RestAPIProviderProtocol = NetworkWeatherManager()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CellWithCollectionView", bundle: nil), forCellReuseIdentifier: "CellWithCollectionView")
        tableView.register(UINib(nibName: "DailyWeatherCell", bundle: nil), forCellReuseIdentifier: "DailyWeatherCell")
        tableView.register(UINib(nibName: "CurrentWeatherCell", bundle: nil), forCellReuseIdentifier: "CurrentWeatherCell")
        
        createAndShowBlurEffectWithActivityIndicator()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        self.addGradient()
        
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = .none
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        tabBarController?.tabBar.backgroundColor = .clear
        tabBarController?.tabBar.scrollEdgeAppearance = appearance
        
        if locationManager.authorizationStatus != .authorizedWhenInUse && locationManager.authorizationStatus != .authorizedAlways {
            networkWeatherManager.getCoordinatesByName(forCity: "Kiev") { [weak self] geoData, weatherData in
                guard let self = self else { return }
                self.saveCurrentData(weatherData: weatherData, geoData: geoData)
                DispatchQueue.main.async {
                    self.realmManager.savaData(data: weatherData)
                    self.updateInterface(hourlyWeather: self.hourlyWeather)
                }
            }
        }
    }
    
    //MARK: - @IBAction
    @IBAction func findCityPressed(_ sender: UIButton) {
        presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert)
    }
    
    @IBAction func refreshTableView() {
        if geoData != nil {
            self.createAndShowBlurEffectWithActivityIndicator()
            guard let cityName = geoData?.first?.cityName else { return }
            self.networkWeatherManager.getCoordinatesByName(forCity: cityName) { [weak self] geoData, weatherData in
                guard let self = self else { return }
                self.saveCurrentData(weatherData: weatherData, geoData: geoData)
                DispatchQueue.main.async {
                    self.realmManager.savaData(data: weatherData)
                    self.updateInterface(hourlyWeather: self.hourlyWeather)
                }
            }
        } else {
            self.createAndShowBlurEffectWithActivityIndicator()
            locationManager.requestLocation()
            guard let coordinate = coordinate else { return }
            self.networkWeatherManager.getWeatherForCityCoordinates(long: coordinate.longitude, lat: coordinate.latitude, withLang: .english, withUnitsOfmeasurement: .celsius) { [weak self] weatherData in
                guard let self = self else { return }
                self.saveCurrentData(weatherData: weatherData, geoData: nil)
                DispatchQueue.main.async {
                    self.realmManager.savaData(data: weatherData)
                    self.updateInterface(hourlyWeather: self.hourlyWeather)
                }
            }
        }
        refresh.endRefreshing()
    }
    
    //MARK: - Methods
    func saveCurrentData(weatherData: WeatherData, geoData: [Geocoding]?) {
        self.currentWeather = weatherData
        self.hourlyWeather = weatherData.hourly
        self.dailyWeather = weatherData.daily
        self.geoData = geoData
    }
    
    func weatherCheck(hourlyWeather: [HourlyWeatherData]?) {
        guard let hourlyWeather = hourlyWeather else { return }
        var index = 0
        for hour in hourlyWeather {
            guard let id = hour.weather?.first?.id, let time = hour.dt else { return }
            //Если плохая погода впервые или перерыв между уведомлениями больше 3х часов, отправляем новое уведомление
            if index == 0 || index > 3 {
                switch id {
                case 200...232:
                    setLocalNotification(body: "soon thunderstorm", title: "Hey!", dateComponents: getDateComponentsFrom(date: time))
                    index = 1
                case 500...531:
                    setLocalNotification(body: "soon rain", title: "Hey!", dateComponents: getDateComponentsFrom(date: time))
                    index = 1
                case 600...622:
                    setLocalNotification(body: "soon snow", title: "Hey!", dateComponents: getDateComponentsFrom(date: time))
                    index = 1
                default: break
                }
            }
            index += 1
        }
    }
    
    func getDateComponentsFrom(date: Int) -> DateComponents {
        let calendar = Calendar.current
        let newDate = Date(timeIntervalSince1970: TimeInterval(date))
        var newDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        guard let minutes = newDateComponents.minute else { fatalError() }
        newDateComponents.minute = minutes - 30
        return newDateComponents
    }
    
    func setLocalNotification(body: String, title: String, dateComponents: DateComponents) {
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
    
    func removeAllNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func updateInterface(hourlyWeather: [HourlyWeatherData]?) {
        if self.geoData == nil {
            self.tableView.reloadData()
            self.title = self.currentWeather?.timeZone
            self.hideBlurView()
        } else {
            guard let name = self.geoData?.first?.cityName,
                  let country = self.geoData?.first?.country else  { return }
            self.tableView.reloadData()
            self.title = "\(name), \(country)"
            self.hideBlurView()
        }
        self.removeAllNotification()
        self.weatherCheck(hourlyWeather: hourlyWeather)
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
            return "Current weather"
        } else if section == 1 {
            return "Hourly forecasts"
        } else {
            return "Daily forecasts"
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
                hourlyCell.hourlyArray = hourlyWeatherData
            }
            return hourlyCell
        } else {
            if let daily = dailyWeather {
                cell.configureDailyCell(data: daily[indexPath.row])
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
        
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            self.networkWeatherManager.getWeatherForCityCoordinates(long: location.longitude, lat: location.latitude, withLang: .english, withUnitsOfmeasurement: .celsius) { [weak self] weatherData in
                guard let self = self else { return }
                self.saveCurrentData(weatherData: weatherData, geoData: nil)
                DispatchQueue.main.async {
                    self.realmManager.savaData(data: weatherData)
                    self.updateInterface(hourlyWeather: self.hourlyWeather)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
