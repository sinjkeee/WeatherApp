import UIKit

class MarkerWindowView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var windSpeedNameLabel: UILabel!
    @IBOutlet weak var tempNameLabel: UILabel!
    
    func configure(weather: WeatherData, url: URL) {
        guard let windSpeed = weather.current?.windSpeed,
              let temperature = weather.current?.temp,
              let data = try? Data(contentsOf: url)
        else { return }
        let isMetric = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true
        let units = isMetric ? Units.metric.distanceString : Units.imperial.distanceString
        let unitsTemp = isMetric ? Units.metric.temperatureString : Units.imperial.temperatureString
        self.windSpeedNameLabel.text = "WIND SPEED".localized()
        self.tempNameLabel.text = "TEMPERATURE MARKER".localized()
        self.imageView.image = UIImage(data: data)
        self.windSpeed.text = "\(windSpeed) \(units)"
        self.temperatureLabel.text = "\(Int(temperature))\(unitsTemp)"
        self.layer.cornerRadius = 40
        self.layer.borderWidth = 1
        self.layer.borderColor = CGColor(red: 20/255, green: 29/255, blue: 188/255, alpha: 1)
        self.addGradient()
    }
    
    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemCyan.cgColor, UIColor.systemBlue.cgColor]
        gradient.opacity = 0.5
        gradient.startPoint = CGPoint(x: 0.1, y: 0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = self.bounds
        gradient.cornerRadius = 40
        self.layer.insertSublayer(gradient, at: 0)
    }
}
