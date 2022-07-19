import UIKit

class SettingsViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var toHistoryVCButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var unitsOfMeasurementButton: UIButton!
    @IBOutlet weak var timeChangeButton: UIButton!
    
    @IBOutlet var buttons: [UIButton]!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        buttons.forEach { button in
            button.cornerRadius()
        }
        self.title = "Settings".localized()
        self.timeChangeButton.setTitle("Time settings".localized(), for: .normal)
        self.unitsOfMeasurementButton.setTitle("Measurements".localized(), for: .normal)
        self.notificationButton.setTitle("Notifications settings".localized(), for: .normal)
        self.toHistoryVCButton.setTitle("Request history".localized(), for: .normal)
    }
    //MARK: - IBAction
    @IBAction func toHistoryVCPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController else { return }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func notificationButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "SelectNotificationSettings") as? SelectNotificationSettings else { return }
        controller.index = 0
        modalPresentationStyle = .popover
        present(controller, animated: true)
    }
    
    @IBAction func unitsOfMeasurementButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "SelectNotificationSettings") as? SelectNotificationSettings else { return }
        controller.index = 2
        modalPresentationStyle = .popover
        present(controller, animated: true)
    }
    
    @IBAction func timeChangeButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "SelectNotificationSettings") as? SelectNotificationSettings else { return }
        controller.index = 1
        modalPresentationStyle = .popover
        present(controller, animated: true)
    }
    
}
