import UIKit
import SnapKit
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController {
    
    //MARK: - let/var
    var mapView = UIView()
    private var realmManager: RealmManagerProtocol = RealmManager()
    private var networkWeatherManager: RestAPIProviderProtocol = NetworkWeatherManager()
    var currentWeather: WeatherData?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let frame = tabBarController?.tabBar.frame.height else { return }
        
        view.layoutIfNeeded()
        view.addSubview(mapView)
        mapView.backgroundColor = .cyan
        
        mapView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(frame)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let currentWeather = self.currentWeather else { return }
            guard let temp = currentWeather.current?.temp else { return }
            self.showAlertWith(temperature: temp)
        }
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        let camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.597, zoom: 6.0)
        let map =  GMSMapView.map(withFrame: mapView.frame, camera: camera)
        map.delegate = self
        self.mapView.addSubview(map)
    }
    
    //MARK: - Methods
    func showAlertWith(temperature temp: Double) {
        let alert = UIAlertController(title: "wou!", message: "Temperature in the region: \(temp) ºC", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - extension GMSMapViewDelegate
extension MapViewController:GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        networkWeatherManager.getWeatherForCityCoordinates(long: coordinate.longitude, lat: coordinate.latitude, withLang: .russian, withUnitsOfmeasurement: .celsius) { weatherData in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard let temp = weatherData.current?.temp else { return }
                self.realmManager.savaData(data: weatherData)
                self.showAlertWith(temperature: temp)
            }
        }
    }
}
