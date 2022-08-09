import UIKit
import RealmSwift
import CoreLocation

class MainViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - let/var
    private let refresh = UIRefreshControl()
    private var realmManager: RealmManagerProtocol = RealmManager()
    var geoData: [Geocoding]?
    private var coordinate: CLLocationCoordinate2D?
    private var currentWeather: WeatherData?
    private var hourlyWeather: [HourlyWeatherData]?
    private var dailyWeather: [DailyWeatherData]?
    private var reverseGeocoding: [ReverseGeocoding]?
    private var citiesArray: [String] = []
    var citiesDict: [String: WeatherData] = [:]
    var weatherForCitiesList = [WeatherData]()
    var networkWeatherManager: RestAPIProviderProtocol = NetworkWeatherManager()
    var units: String = ""
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.units = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true ? "metric" : "imperial"
        self.geoData = nil
        
        tableView.register(UINib(nibName: "CellWithCollectionView", bundle: nil), forCellReuseIdentifier: "CellWithCollectionView")
        tableView.register(UINib(nibName: "DailyWeatherCell", bundle: nil), forCellReuseIdentifier: "DailyWeatherCell")
        tableView.register(UINib(nibName: "CurrentWeatherCell", bundle: nil), forCellReuseIdentifier: "CurrentWeatherCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresh
        
        refresh.addTarget(self, action: #selector(updateTableView), for: .valueChanged)
        
        self.addGradient()
    }

    //MARK: - @IBAction
    @IBAction func listOfCitiesPressed(_ sender: UIBarButtonItem) {
        guard let citiesNaviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CitiesNaviController") as? UINavigationController else { return }
        guard let controller = citiesNaviController.viewControllers.first as? CitiesViewController else { return }
        controller.weatherForCities = weatherForCitiesList
        present(citiesNaviController, animated: true)
    }
    
    func updateCitiesTableView(with weather: [WeatherData]) {
        guard let citiesNaviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CitiesNaviController") as? UINavigationController else { return }
        guard let controller = citiesNaviController.viewControllers.first as? CitiesViewController else { return }
        controller.weatherForCities = weather
        controller.loadViewIfNeeded()
        controller.reload()
    }
    
    @objc func updateTableView() {
        NotificationCenter.default.post(name: .updateMainInterface, object: nil, userInfo: nil)
        refresh.endRefreshing()
    }
        
    //MARK: - Methods
    func combiningMethods(weatherData: WeatherData) {
        //self.geoData = weatherData.1
        self.saveCurrentData(weatherData: weatherData)
        DispatchQueue.main.async {
            self.realmManager.savaData(data: weatherData, isMap: false)
            //self.updateInterface(hourlyWeather: self.hourlyWeather)
            self.title = weatherData.name
            self.loadViewIfNeeded()
            self.tableView.reloadData()
        }
    }
    
    private func saveCurrentData(weatherData: WeatherData) {
        self.currentWeather = weatherData
        self.hourlyWeather = weatherData.hourly
        self.dailyWeather = weatherData.daily
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
        loadViewIfNeeded()
        self.tableView.reloadData()
    }
    
    private func getWeatherForCities(cities: [String], completionHandler: @escaping (WeatherData, String) -> Void) {
        for name in cities {
            self.networkWeatherManager.getCoordinatesByName(forCity: name) { [weak self] (result: Result<[Geocoding], Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    guard let lon = success.first?.lon, let lat = success.first?.lat else { return }
                    self.networkWeatherManager.getWeatherForCityCoordinates(long: lon, lat: lat, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                        switch result {
                        case .success(let weather):
                            completionHandler(weather, name)
                        case .failure(let failure):
                            print(failure.localizedDescription)
                        }
                    }
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemCyan.cgColor, UIColor.systemBlue.cgColor]
        gradient.opacity = 0.5
        gradient.startPoint = CGPoint(x: 0.1, y: 0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
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
