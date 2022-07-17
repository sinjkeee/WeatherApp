import UIKit

class CurrentWeatherCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageViewForCurrentWeather: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var feelsLike: UILabel!
    @IBOutlet weak var humidity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.windSpeed.text = "WIND SPEED".localized()
        self.feelsLike.text = "FEELS LIKE".localized()
        self.humidity.text = "HUMIDITY".localized()
    }
    
    func configureCurrentWeatherCell(data: WeatherData) {
        guard let description = data.current?.weather?.first?.description,
              let icon = data.current?.weather?.first?.icon,
              let temp = data.current?.temp,
              let feelsLikeTemp = data.current?.feelsLike,
              let windSpeed = data.current?.windSpeed,
              let humidity = data.current?.humidity
        else { return }
        
        let isMetric = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true
        let unitsTemp = isMetric ? "˚C" : "˚F"
        let units = isMetric ? "km/h".localized() : "ml/h".localized()
        self.descriptionLabel.text = description.capitalized
        self.imageViewForCurrentWeather.getImageFromTheInternet(icon)
        self.temperatureLabel.text = "\(Int(temp))˚"
        self.feelsLikeLabel.text = "\(Int(feelsLikeTemp))\(unitsTemp)"
        self.humidityLabel.text = "\(humidity) %"
        self.windSpeedLabel.text = "\(windSpeed) \(units)"
    }
}
