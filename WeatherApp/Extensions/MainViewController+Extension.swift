import Foundation
import UIKit
import SnapKit

extension MainViewController {
    func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let searchButton = UIAlertAction(title: "Search", style: .cancel) { _ in
            guard let textField = alert.textFields?.first else { return }
            guard let cityName = textField.text else { return }
            if textField.hasText {
                self.createAndShowBlurEffectWithActivityIndicator()
                self.networkWeatherManager.getCoordinatesByName(forCity: cityName) { [weak self] (result: Result<[Geocoding], Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            self.hideBlurView()
                            self.showErrorAlert(title: "Oops", message: "Something went wrong. Check city name and try again")
                        }
                    case .success(let geocoding):
                        self.geoData = geocoding
                        guard let longitude = geocoding.first?.lon, let latitude = geocoding.first?.lat else { return }
                        self.networkWeatherManager.getWeatherForCityCoordinates(long: longitude, lat: latitude, withLang: .english, withUnitsOfmeasurement: .celsius) { (result: Result<WeatherData, Error>) in
                            switch result {
                            case .failure(let error):
                                print(error.localizedDescription)
                                DispatchQueue.main.async {
                                    self.hideBlurView()
                                    self.showErrorAlert(title: "Oops", message: "Something went wrong. Check city name and try again")
                                }
                            case .success(let weatherData):
                                self.combiningMethods(weatherData: weatherData)
                                DispatchQueue.main.async {
                                    self.getLocationButton.tintColor = .systemCyan
                                    UserDefaults.standard.removeObject(forKey: "location")
                                    UserDefaults.standard.set("\(cityName)", forKey: "city")
                                }
                            }
                        }
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
            make.top.bottom.right.left.equalToSuperview()
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
        var _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
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
    
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okeyButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okeyButton)
        present(alertController, animated: true)
    }
}
