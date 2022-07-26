import UIKit

class CitiesViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var citiesTableView: UITableView!
    
    //MARK: - let/var
    var citiesDictionary: [String: WeatherData] = [:]
    var citiesNames: [String] = []
    var citiesWeather: [WeatherData] = []
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for city in citiesDictionary {
            citiesNames.append(city.key)
            citiesWeather.append(city.value)
        }
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        citiesTableView.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "CityCell")
        self.title = "Cities".localized()
    }
    
    //MARK: - IBAction
    @IBAction func addNewCityPressed(_ sender: UIBarButtonItem) {
        
    }
}

//MARK: - extension table view
extension CitiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = citiesTableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as? CityCell else { return UITableViewCell() }
        cell.updateCell(name: citiesNames[indexPath.row], weather: citiesWeather[indexPath.row])
        return cell
    }
    
}
