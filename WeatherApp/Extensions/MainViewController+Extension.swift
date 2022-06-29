import Foundation
import UIKit

extension MainViewController {
    func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let searchButton = UIAlertAction(title: "Search", style: .cancel) { _ in
            let textField = alert.textFields?.first
            guard let cityName = textField?.text else { return }
            if cityName != "" {
                self.networkWeatherManager.getCoordinatesByName(forCity: cityName) { [weak self] weatherData in
                    guard let self = self else { return }
                    self.currentWeather = weatherData
                    self.hourlyWeather = weatherData.hourly
                    self.dailyWeather = weatherData.daily
                    self.updateInterface()
                    self.realm.savaData(data: weatherData)
                }
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addTextField { textField in
            let cities = ["Moscow", "Minsk", "Istambul", "Viena", "Brest"]
            textField.placeholder = cities.randomElement()
        }
        
        alert.addAction(searchButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
}
