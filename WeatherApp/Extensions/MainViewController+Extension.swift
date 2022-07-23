import Foundation
import UIKit
import SnapKit

extension MainViewController {
    func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let searchButton = UIAlertAction(title: "Search".localized(), style: .cancel) { _ in
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
                            self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                        }
                    case .success(let geocoding):
                        if !geocoding.isEmpty {
                            self.geoData = geocoding
                            guard let longitude = geocoding.first?.lon, let latitude = geocoding.first?.lat else { return }
                            self.networkWeatherManager.getWeatherForCityCoordinates(long: longitude, lat: latitude, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
                                switch result {
                                case .failure(let error):
                                    print(error.localizedDescription)
                                    DispatchQueue.main.async {
                                        self.hideBlurView()
                                        self.showErrorAlert(title: "Oops".localized(), message: "Something went wrong".localized())
                                    }
                                case .success(let weatherData):
                                    self.combiningMethods(weatherData: weatherData)
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.removeObject(forKey: "location")
                                        UserDefaults.standard.removeObject(forKey: "city")
                                        UserDefaults.standard.set("\(cityName)", forKey: "city")
                                        self.getLocationButton.tintColor = .systemCyan
                                        self.findCityButton.tintColor = .systemPink
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.hideBlurView()
                                self.showErrorAlert(title: "City not found!".localized(), message: "Check city name and try again".localized())
                            }
                        }
                    }
                }
            }
        }
        
        let cancelButton = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        alert.addTextField { textField in
            let cities = ["Moscow".localized(), "Minsk".localized(), "Istambul".localized(), "Viena".localized(), "Brest".localized()]
            textField.placeholder = cities.randomElement()
            textField.delegate = self
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
        let okeyButton = UIAlertAction(title: "Ok".localized(), style: .default, handler: nil)
        alertController.addAction(okeyButton)
        present(alertController, animated: true)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if CharacterSet(charactersIn: "qwertyuiopasdfghjklzxcvbnm ёйцукенгшщзхъфывапролджэячсмитьбю QWERTYUIOPASDFGHJKLZXCVBNM ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ-").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        } else {
            return false
        }
    }
}
