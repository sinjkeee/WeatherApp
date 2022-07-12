import UIKit

class MyHourlyCell: UICollectionViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(weather: HourlyWeatherData, isFirst: Bool) {
        guard let icon = weather.weather?.first?.icon,
              let temp = weather.temp,
              let time = weather.dt?.changeDate(dateFormat: .hours)
        else { return }
        timeLabel.text = isFirst ? "Now".localized() : "\(time)"
        imageView.getImageFromTheInternet(icon)
        temperatureLabel.text = "\(Int(temp))˚"
    }
}
