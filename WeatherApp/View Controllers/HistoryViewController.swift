import UIKit
import RealmSwift
import SnapKit

class HistoryViewController: UIViewController {
    
    //MARK: - let/var
    private var realmManager: RealmManagerProtocol = RealmManager()
    var arrayData: [CurrentWeatherForRealm] = []
    var historyTableView = UITableView()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView = UITableView(frame: view.bounds, style: .plain)
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        view.addSubview(historyTableView)
        
        guard let frame = tabBarController?.tabBar.frame.height else { return }
        
        historyTableView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width)
            make.height.equalTo(view.frame.height - frame)
            make.left.right.equalToSuperview().inset(0)
            make.top.equalToSuperview().inset(16)
        }
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        refreshData()
    }
    
    //MARK: - @IBAction / Methods
    func refreshData() {
        arrayData = self.realmManager.loadData()
        historyTableView.reloadData()
    }
}

//MARK: - extension TableView
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
