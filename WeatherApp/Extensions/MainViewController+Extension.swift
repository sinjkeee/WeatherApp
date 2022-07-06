import Foundation
import UIKit
import SnapKit

extension MainViewController {
    func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let searchButton = UIAlertAction(title: "Search", style: .cancel) { _ in
            let textField = alert.textFields?.first
            guard let cityName = textField?.text else { return }
            if cityName != "" {
                self.networkWeatherManager.getCoordinatesByName(forCity: cityName) { [weak self] geoData, weatherData in
                    guard let self = self else { return }
                    self.currentWeather = weatherData
                    self.hourlyWeather = weatherData.hourly
                    self.dailyWeather = weatherData.daily
                    self.geoData = geoData
                    DispatchQueue.main.async {
                        self.realmManager.savaData(data: weatherData)
                        guard let weather = self.hourlyWeather else { return }
                        self.updateInterface()
                        self.removeAllNotification()
                        self.weatherCheck(hourlyWeather: weather)
                    }
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
    
    func createAndShowBlurEffectWithActivityIndicator() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        tabBarController?.view.addSubview(blurView)
        blurView.alpha = 1
        blurView.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview().inset(0)
        }
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        blurView.contentView.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        activityIndicator.startAnimating()
    }
    
    func hideBlurView() {
        var _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] _ in
            guard let self = self,
                  let views = self.tabBarController?.view.subviews else { return }
            for view in views where view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        })
    }
    
    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemYellow.cgColor, UIColor.systemCyan.cgColor, UIColor.systemBlue.cgColor]
        gradient.opacity = 0.5
        gradient.startPoint = CGPoint(x: 0.1, y: 0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
}
