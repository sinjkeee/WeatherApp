import UIKit

class CityCell: UITableViewCell {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var descriptionCityWeatherLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(name: String, weather: WeatherData) {
        guard let temp = weather.current?.temp,
              let descriprion = weather.current?.weather?.first?.description
        else { return }
        self.cityNameLabel.text = name
        self.currentTemperatureLabel.text = ("\(Int(temp))˚")
        self.descriptionCityWeatherLabel.text = descriprion
    }
    
}
