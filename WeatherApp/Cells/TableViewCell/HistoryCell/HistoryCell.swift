import UIKit
import SnapKit

class HistoryCell: UITableViewCell {

    var dateLabel = UILabel()
    var coordinateLabel = UILabel()
    var temperatureLabel = UILabel()
    var cityName = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cityName.text = ""
        dateLabel.text = ""
        coordinateLabel.text = ""
        temperatureLabel.text = ""
        cityName.textColor = .red
        contentView.addSubview(dateLabel)
        contentView.addSubview(cityName)
        contentView.addSubview(coordinateLabel)
        contentView.addSubview(temperatureLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalToSuperview().inset(8)
            make.right.left.equalToSuperview().inset(16)
        }
        
        cityName.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.right.left.equalToSuperview().inset(16)
            make.top.equalTo(dateLabel.snp.bottom).inset(4)
        }
        
        coordinateLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(cityName.snp.bottom).inset(4)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.right.left.equalToSuperview().inset(16)
            make.top.equalTo(coordinateLabel.snp.bottom).inset(4)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configure(data: CurrentWeatherForRealm) {
        guard let long = data.coordinate?.lot, let latit = data.coordinate?.lat else { return }
        self.dateLabel.text = data.time.changeDate(dateFormat: .fullTime)
        self.coordinateLabel.text = "longitude: \(long) latitude: \(latit)"
        self.temperatureLabel.text = "температура: \(Int(data.temp)) °C"
        self.cityName.text = data.timeZone
    }
    
}
