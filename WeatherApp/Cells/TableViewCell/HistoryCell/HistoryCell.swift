import UIKit
import SnapKit

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var longNameLabel: UILabel!
    @IBOutlet weak var longValueLabel: UILabel!
    @IBOutlet weak var latNameLabel: UILabel!
    @IBOutlet weak var latValueLabel: UILabel!
    @IBOutlet weak var tempNameLabel: UILabel!
    @IBOutlet weak var tempValueLabel: UILabel!
    @IBOutlet weak var windSpeedNameLabel: UILabel!
    @IBOutlet weak var windSpeedValueLabel: UILabel!
    @IBOutlet weak var fromDataLabel: UILabel!
      
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.longNameLabel.text = "Longitude:".localized()
        self.latNameLabel.text = "Latitude:".localized()
        self.tempNameLabel.text = "Temperature:".localized()
        self.windSpeedNameLabel.text = "Wind speed:".localized()
    }
    
    func configure(data: CurrentWeatherForRealm) {
        guard let long = data.coordinate?.lot, let lat = data.coordinate?.lat else { return }
        self.dateLabel.text = data.time.changeDate(dateFormat: .fullTime).capitalized
        self.longValueLabel.text = "\(long)"
        self.latValueLabel.text = "\(lat)"
        self.tempValueLabel.text = "\(data.temp)˚"
        self.windSpeedValueLabel.text = "\(data.windSpeed)"+"km/h HistoryCell".localized()
        self.fromDataLabel.text = data.isMap ? "Data from the request from the maps".localized() : "Data from the request from the main screen".localized()
    }
}
