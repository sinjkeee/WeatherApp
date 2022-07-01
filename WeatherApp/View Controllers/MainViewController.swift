import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dailyTableView: UITableView!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    
    //MARK: - let/var
    var realmManager: RealmManagerProtocol = RealmManager()
    var currentWeather: WeatherData?
    var hourlyWeather: [HourlyWeatherData]?
    var dailyWeather: [DailyWeatherData]?
    var networkWeatherManager: RestAPIProviderProtocol = NetworkWeatherManager()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyTableView.register(UINib(nibName: "DailyWeatherCell", bundle: nil), forCellReuseIdentifier: "DailyWeatherCell")
        hourlyCollectionView.register(UINib(nibName: "HourlyCell", bundle: nil), forCellWithReuseIdentifier: "HourlyCell")
        
        networkWeatherManager.getCoordinatesByName(forCity: "Kiev") { [weak self] weatherData in
            guard let self = self else { return }
            self.currentWeather = weatherData
            self.hourlyWeather = weatherData.hourly
            self.dailyWeather = weatherData.daily
            self.updateInterface()
            DispatchQueue.main.async {
                self.realmManager.savaData(data: weatherData)
                guard let weather = self.hourlyWeather else { return }
                self.removeAllNotification()
                self.weatherCheck(weather: weather)
            }
        }
        
        dailyTableView.delegate = self
        dailyTableView.dataSource = self
        hourlyCollectionView.delegate = self
        hourlyCollectionView.dataSource = self
    }
    
    //MARK: - @IBAction
    @IBAction func findCityPressed(_ sender: UIButton) {
        presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert)
    }
    
    //MARK: - Methods
    func weatherCheck(weather: [HourlyWeatherData]) {
        for hour in weather {
            guard let id = hour.weather?.first?.id,
                  let time = hour.dt else { return }
//            let currentDate = Date()
//            let newDate = Date(timeIntervalSince1970: TimeInterval(time))
//            let timeEnterval = newDate.timeIntervalSince(currentDate) / 60 - 30
//            print(timeEnterval)
            let calendar = Calendar.current
            let newDate = Date(timeIntervalSince1970: TimeInterval(time))
            var newDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
            guard let minutes = newDateComponents.minute else { return }
            newDateComponents.minute = minutes - 30
//            let newCalendar = calendar.date(from: newDateComponents)
            
            
            switch id {
            case 200...232:
                setLocalNotification(body: "soon thunderstorm", title: "Hey!", dateComponents: newDateComponents)
            case 500...531:
                setLocalNotification(body: "soon rain", title: "Hey!", dateComponents: newDateComponents)
            case 600...622:
                setLocalNotification(body: "soon snow", title: "Hey!", dateComponents: newDateComponents)
            default: break
            }
        }
    }
    
    func setLocalNotification(body: String, title: String, dateComponents: DateComponents) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { isAutorized, error in
            if isAutorized {
                let content = UNMutableNotificationContent()
                content.body = body
                content.title = title
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let identifier = "identifier"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
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
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func updateInterface() {
        guard let weather = currentWeather,
              let icon = weather.current?.weather?.first?.icon else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let temp = weather.current?.temp,
                  let feelsLikeTemp = weather.current?.feelsLike,
                  let cityName = weather.timeZone,
                  let description = weather.current?.weather?.first?.description,
                  let self = self
            else { return }
            
            self.imageView.getImageFromTheInternet(icon)
            self.tempLabel.text = "температура: \(Int(temp)) °C"
            self.feelsLikeTemp.text = "ощущается как: \(Int(feelsLikeTemp)) °C"
            self.cityName.text = cityName
            self.descriptionLabel.text = description
            self.dailyTableView.reloadData()
            self.hourlyCollectionView.reloadData()
        }
    }
}

//MARK: - extension TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentWeather?.daily?.count ?? 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyWeatherCell") as? DailyWeatherCell else { return UITableViewCell() }
        if let daily = dailyWeather {
            cell.configure(data: daily[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - extension CollectionView
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentWeather?.hourly?.count ?? 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as? HourlyCell else { return UICollectionViewCell() }
        if let hourly = hourlyWeather {
            cell.configure(data: hourly[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
