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
       
        networkWeatherManager.completion = { [weak self] currentWeather in
            guard let self = self else { return }
            self.updateInterface(weather: currentWeather)
        }
        
        networkWeatherManager.fetchCurrentWeather(forCity: "Istambul", withLang: .russian)
    }
    
    
    @IBAction func findCityPressed(_ sender: UIButton) {
        presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert)
    }
    
    func updateInterface(weather: CurrentWeatherData) {
        DispatchQueue.main.async {
            guard let systemIcon = weather.weather?.first?.systemIconName,
                  let temp = weather.main?.temp,
                  let feelsLikeTemp = weather.main?.feelsLike,
                  let cityName = weather.name,
                  let description = weather.weather?.first?.description
            else { return }
            
            self.imageView.image = UIImage(systemName: systemIcon)
            self.tempLabel.text = "температура: \(Int(temp))"
            self.feelsLikeTemp.text = "ощущается как: \(Int(feelsLikeTemp))"
            self.cityName.text = cityName
            self.descriptionLabel.text = description
        }
    }
    
}

