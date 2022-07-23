import UIKit

class CitiesViewController: UIViewController {
    
    @IBOutlet weak var citiesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cities".localized()
    }
    
    @IBAction func addNewCityPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
}
