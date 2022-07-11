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
    var map = GMSMapView()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let frame = tabBarController?.tabBar.frame.height else { return }
        
        view.layoutIfNeeded()
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(frame)
        }
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        let camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.597, zoom: 6.0)
        map =  GMSMapView.map(withFrame: mapView.frame, camera: camera)
        map.delegate = self
        self.mapView.addSubview(map)
    }
    
    //MARK: - Methods
    func createMarker(map: GMSMapView, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        map.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.map = map
    }
}

//MARK: - extension GMSMapViewDelegate
extension MapViewController:GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        networkWeatherManager.getWeatherForCityCoordinates(long: coordinate.longitude, lat: coordinate.latitude, withLang: .russian, withUnitsOfmeasurement: .celsius) { (result: Result<WeatherData, Error>) in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.realmManager.savaData(data: weatherData)
                    self.currentWeather = weatherData
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        self.createMarker(map: map, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let view = Bundle.main.loadNibNamed("MarkerWindowView", owner: self)?[0] as? MarkerWindowView else { return UIView() }
        
        if let weather = currentWeather, let icon = weather.current?.weather?.first?.icon {
            let endpoint = Endpoint.getIcon(icon: icon)
            guard let url = endpoint.url else { fatalError() }
            view.configure(weather: weather, url: url)
        }
        return view
    }
}
