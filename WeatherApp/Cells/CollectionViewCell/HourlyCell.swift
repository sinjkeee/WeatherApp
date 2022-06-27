import UIKit
import SnapKit

class HourlyCell: UICollectionViewCell {
    
    var firstLabel = UILabel()
    var secondLabel = UILabel()
    var iconImage = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        iconImage.contentMode = .scaleAspectFit
        iconImage.image = UIImage(systemName: "")
        firstLabel.text = ""
        secondLabel.text = ""
        firstLabel.textAlignment = .center
        secondLabel.textAlignment = .center
        firstLabel.font = UIFont.systemFont(ofSize: 17)
        secondLabel.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
        contentView.addSubview(iconImage)
        
        firstLabel.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.top.right.left.equalToSuperview().inset(8)
        }
        
        iconImage.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(firstLabel.snp.bottom).inset(8)
            make.bottom.equalTo(secondLabel.snp.top).inset(8)
        }
        
        secondLabel.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.left.right.bottom.equalToSuperview().inset(8)
        }
        
        self.backgroundColor = .systemTeal
    }
    
    func configure(data: HourlyWeatherData) {
        guard let icon = data.weather?.first?.icon, let dt = data.dt, let temp = data.temp else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.iconImage.getImageFromTheInternet(icon)
            self.firstLabel.text = dt.dateFormatter(isTime: true)
            self.secondLabel.text = "\(Int(temp)) °C"
        }
    }
}
