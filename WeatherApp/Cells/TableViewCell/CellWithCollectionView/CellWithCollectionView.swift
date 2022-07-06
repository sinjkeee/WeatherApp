import UIKit

class CellWithCollectionView: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var hourlyArray: [HourlyWeatherData] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "MyHourlyCell", bundle: nil), forCellWithReuseIdentifier: "MyHourlyCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatedCollectionView), name: .collectionViewUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func updatedCollectionView() {
        collectionView.reloadData()
    }
    
}


extension CellWithCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyHourlyCell", for: indexPath) as? MyHourlyCell else { return UICollectionViewCell() }
        
        cell.configure(weather: hourlyArray[indexPath.item], isFirst: indexPath.item == 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
