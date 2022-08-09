import UIKit

class CitiesViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var citiesTableView: UITableView!
    
    //MARK: - let/var
    var citiesWeather: [WeatherData] = []
    var networkWeatherManager: RestAPIProviderProtocol = NetworkWeatherManager()
    var weatherForCities = [WeatherData]()
    var units: String = ""
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.units = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true ? "metric" : "imperial"
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        citiesTableView.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "CityCell")
        self.title = "Cities".localized()
    }
    
    //MARK: - IBAction
    @IBAction func addNewCityPressed(_ sender: UIBarButtonItem) {
        presentSearchAlertController(withTitle: "Enter city name".localized(), message: nil, style: .alert)
    }
    
    func reload() {
        citiesTableView.reloadData()
    }
}


//MARK: - extension table view
extension CitiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherForCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = citiesTableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as? CityCell else { return UITableViewCell() }
        cell.updateCell(name: weatherForCities[indexPath.row].name ?? "Name", weather: weatherForCities[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard var citiesArray = UserDefaults.standard.value(forKey: "cities2") as? [String: [Double]] else { return }
            
            let weather = weatherForCities[indexPath.row]
            let lon = Int(weather.lon!)
            let lat = Int(weather.lat!)
            
            // Поиск и удаление города из бд и из таблицы
            for city in citiesArray {
                if lon == Int(city.value[0]) || lat == Int(city.value[1]) {
                    citiesArray[city.key] = nil
                    weatherForCities.remove(at: indexPath.row)
                    UserDefaults.standard.set(citiesArray, forKey: "cities2")
                    NotificationCenter.default.post(name: .updateMainInterface, object: nil, userInfo: nil)
                    tableView.reloadData()
                }
            }
        }
    }
    
}
