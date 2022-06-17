import UIKit

class ViewController: UIViewController {

    let networkWeatherManager = NetworkWeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        networkWeatherManager.fetchCurrentWeather(forCity: "Minsk")
    }
}

