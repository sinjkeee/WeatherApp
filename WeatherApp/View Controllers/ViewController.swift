import UIKit

class MainViewController: UIViewController {

    let networkWeatherManager = NetworkWeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        networkWeatherManager.fetchCurrentWeather(forCity: "Moscow")
    }
}

