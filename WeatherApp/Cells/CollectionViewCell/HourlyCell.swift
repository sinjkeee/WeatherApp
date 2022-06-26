import UIKit
import SnapKit

class HourlyCell: UICollectionViewCell {
    
    var firstLabel = UILabel()
    var secondLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        firstLabel.text = ""
        secondLabel.text = ""
        firstLabel.numberOfLines = 0
        secondLabel.numberOfLines = 0
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
        
        firstLabel.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(50)
            make.top.right.left.equalToSuperview().inset(16)
        }
        
        secondLabel.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(50)
            make.left.right.bottom.equalToSuperview().inset(16)
            make.top.equalTo(firstLabel.snp.bottom).inset(16)
        }
        
        self.backgroundColor = .systemTeal
    }
    
    func configure(data: HourlyWeatherData) {
        if let dt = data.dt, let temp = data.temp {
            let date = daysFormatter(dt: dt)
            firstLabel.text = date
            secondLabel.text = "\(Int(temp)) °C"
        }
    }
    
    func daysFormatter(dt: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    
}
