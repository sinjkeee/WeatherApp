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
    var camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.597, zoom: 6.0)
    var units: String = ""
    
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
        //self.camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.597, zoom: 6.0)
        map = GMSMapView.map(withFrame: mapView.frame, camera: self.camera)
        map.delegate = self
        self.mapView.addSubview(map)
    }
    
    //MARK: - Methods
    func createMarker(map: GMSMapView, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        map.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.map = map
        map.selectedMarker = marker
    }
}

//MARK: - extension GMSMapViewDelegate
extension MapViewController:GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.units = UserDefaults.standard.value(forKey: "isMetric") as? Bool ?? true ? "metric" : "imperial"
        networkWeatherManager.getWeatherForCityCoordinates(long: coordinate.longitude, lat: coordinate.latitude, language: "languages".localized(), units: self.units) { (result: Result<WeatherData, Error>) in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.realmManager.savaData(data: weatherData, isMap: true)
                    self.currentWeather = weatherData
                    self.createMarker(map: self.map, latitude: coordinate.latitude, longitude: coordinate.longitude)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
