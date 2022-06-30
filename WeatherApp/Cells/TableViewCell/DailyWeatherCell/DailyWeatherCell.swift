import UIKit
import SnapKit

class DailyWeatherCell: UITableViewCell {
    
    var firstLabel = UILabel()
    var secondLabel = UILabel()
    var thirdLabel = UILabel()
    var imageWeather = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageWeather.contentMode = .scaleAspectFit
        imageWeather.image = UIImage(systemName: "")
        firstLabel.text = ""
        secondLabel.text = ""
        thirdLabel.text = ""
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
        contentView.addSubview(thirdLabel)
        contentView.addSubview(imageWeather)
        
        firstLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.left.equalToSuperview().inset(16)
            make.right.equalTo(imageWeather.snp.left).inset(16)
        }
        
        secondLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(firstLabel.snp.bottom).offset(8)
            make.right.equalTo(imageWeather.snp.left).inset(16)
        }
        
        thirdLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(secondLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(16)
            make.right.equalTo(imageWeather.snp.left).inset(16)
        }
        
        imageWeather.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(16)
            make.left.equalTo(secondLabel.snp.right).inset(16)
        }
        
        self.backgroundColor = .systemTeal
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(data: DailyWeatherData) {
        guard let dt = data.dt,
              let temp = data.temp?.day,
              let icon = data.weather?.first?.icon
        else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageWeather.getImageFromTheInternet(icon)
            self.firstLabel.text = dt.changeDate(dateFormat: .days)
            self.secondLabel.text = "температура днем: \(Int(temp)) °C"
            self.thirdLabel.text = data.weather?.first?.description
        }
    }
}
