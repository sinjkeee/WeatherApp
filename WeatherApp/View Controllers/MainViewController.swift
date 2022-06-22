import UIKit

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var networkWeatherManager = NetworkWeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkWeatherManager.geocoding(forCity: "Pinsk")
        
        networkWeatherManager.completion = { [weak  self] currentWeather in
            guard let self = self else { return }
            self.updateInterface(weather: currentWeather)
        }
    }
    
    
    @IBAction func findCityPressed(_ sender: UIButton) {
        presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert)
    }
    
    func updateInterface(weather: CurrentWeatherData) {
        guard let icon = weather.current?.weather?.first?.icon else { return }
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let url = iconURL,
                  let iconData = try? Data(contentsOf: url),
                  let self = self
            else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.imageView.image = UIImage(data: iconData)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let temp = weather.current?.temp,
                  let feelsLikeTemp = weather.current?.feelsLike,
                  let cityName = weather.timeZone,
                  let description = weather.current?.weather?.first?.description,
                  let self = self
            else { return }
            
            self.tempLabel.text = "температура: \(Int(temp))"
            self.feelsLikeTemp.text = "ощущается как: \(Int(feelsLikeTemp))"
            self.cityName.text = cityName
            self.descriptionLabel.text = description
        }
    }
    
}

