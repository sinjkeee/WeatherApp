import UIKit

class MarkerWindowView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    func configure(weather: WeatherData, url: URL) {
        guard let windSpeed = weather.current?.windSpeed,
              let temperature = weather.current?.temp,
              let data = try? Data(contentsOf: url)
        else { return }
        self.imageView.image = UIImage(data: data)
        self.windSpeed.text = "\(windSpeed) km/h"
        self.temperatureLabel.text = "\(temperature)˚"
    }
}
