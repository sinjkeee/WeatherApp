import UIKit
import SnapKit

class DailyWeatherCell: UITableViewCell {
    
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var imageViewForThisCell: UIImageView!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var tmepMinLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureDailyCell(data: DailyWeatherData, isFirst: Bool) {
        guard let icon = data.weather?.first?.icon,
              let windSpeed = data.windSpeed,
              let tempMax = data.temp?.max,
              let tempMin = data.temp?.min
        else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dayNameLabel.text = isFirst ? "Today" : data.dt?.changeDate(dateFormat: .weekday)
            self.imageViewForThisCell.getImageFromTheInternet(icon)
            self.windSpeedLabel.text = "\(windSpeed)"
            self.tempMaxLabel.text = "\(Int(tempMax))˚"
            self.tmepMinLabel.text = "\(Int(tempMin))˚"
        }
    }
}
