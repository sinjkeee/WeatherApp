import UIKit
import RealmSwift
import SnapKit

class HistoryViewController: UIViewController {

    var realm = try! Realm()
    var arrayData: [CurrentWeatherForRealm] = []
    var button = UIButton()
    var historyTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button = UIButton(type: .roundedRect)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 10
        button.setTitle("Refresh TableView", for: .normal)
        button.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        view.addSubview(button)
        
        historyTableView = UITableView(frame: view.bounds, style: .plain)
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        view.addSubview(historyTableView)
        
        guard let frame = tabBarController?.tabBar.frame.height else { return }
        
        button.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(150)
            make.top.equalToSuperview().inset(32)
            make.right.equalToSuperview().inset(16)
        }
        
        historyTableView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width)
            make.height.equalTo(view.frame.height - frame - button.frame.maxY)
            make.left.right.equalToSuperview().inset(0)
            make.top.equalTo(button.snp.bottom).offset(8)
        }
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        var configuration = Realm.Configuration()
        configuration.deleteRealmIfMigrationNeeded = true
        do {
            realm = try Realm(configuration: configuration)
        } catch let error {
            print(error)
        }
        refreshData()
    }
    
    @IBAction func pressedButton(sender: UIButton) {
        refreshData()
    }

    func refreshData() {
        arrayData = realm.objects(CurrentWeatherForRealm.self).map{$0}.reversed()
        historyTableView.reloadData()
    }
}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = historyTableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else { return UITableViewCell() }
        cell.configure(data: arrayData[indexPath.row])
        return cell
    }
}
