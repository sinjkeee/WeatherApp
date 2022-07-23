import UIKit

class SelectNotificationSettings: UIViewController {
    //MARK: - IBOutlets
    // notification settings outlets
    @IBOutlet weak var stormButton: UIButton!
    @IBOutlet weak var rainButton: UIButton!
    @IBOutlet weak var snowButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var notificationSettingsView: UIView!
    // time settings outlets
    @IBOutlet weak var timeSettingsView: UIView!
    @IBOutlet weak var firstTimeButton: UIButton!
    @IBOutlet weak var secondTimeButton: UIButton!
    @IBOutlet weak var saveTimeSettingsButton: UIButton!
    // units of measurement outlets
    @IBOutlet weak var unitsOfMeasurementView: UIView!
    @IBOutlet weak var metricUnitsButton: UIButton!
    @IBOutlet weak var imperialUnitsButton: UIButton!
    @IBOutlet weak var saveUnitsSettingsButton: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    
    var index = 0
    private var array: [Bool] = []
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        array = [false, false, false]
        buttons.forEach { button in
            button.cornerRadius()
        }
        
        updateStartInterface()
        
        self.saveButton.setTitle("Apply".localized(), for: .normal)
        self.saveTimeSettingsButton.setTitle("Apply".localized(), for: .normal)
        self.saveUnitsSettingsButton.setTitle("Apply".localized(), for: .normal)
        
        self.snowButton.setTitle("Snow".localized(), for: .normal)
        self.rainButton.setTitle("Rain".localized(), for: .normal)
        self.stormButton.setTitle("Thunderstorm".localized(), for: .normal)
        
        self.metricUnitsButton.setTitle("Metric".localized(), for: .normal)
        self.imperialUnitsButton.setTitle("Imperial".localized(), for: .normal)
        
        if index == 0 {
            notificationSettingsView.isHidden = false
            timeSettingsView.isHidden = true
            unitsOfMeasurementView.isHidden = true
        } else if index == 1 {
            notificationSettingsView.isHidden = true
            timeSettingsView.isHidden = false
            unitsOfMeasurementView.isHidden = true
        } else if index == 2 {
            unitsOfMeasurementView.isHidden = false
            notificationSettingsView.isHidden = true
            timeSettingsView.isHidden = true
        }
        
    }
    
    //MARK: - Methods
    private func updateStartInterface() {
        let unitsTime = UserDefaults.standard.value(forKey: "timeSetting") as? Bool
        if unitsTime ?? false {
            self.firstTimeButton.isSelected = true
            self.firstTimeButton.layer.borderWidth = 1
            self.firstTimeButton.layer.borderColor = UIColor.red.cgColor
        } else {
            self.secondTimeButton.isSelected = true
            self.secondTimeButton.layer.borderWidth = 1
            self.secondTimeButton.layer.borderColor = UIColor.red.cgColor
        }
        
        let unitsOfMeasurement = UserDefaults.standard.value(forKey: "isMetric") as? Bool
        if unitsOfMeasurement ?? true {
            self.metricUnitsButton.isSelected = true
            self.metricUnitsButton.layer.borderWidth = 1
            self.metricUnitsButton.layer.borderColor = UIColor.red.cgColor
        } else {
            self.imperialUnitsButton.isSelected = true
            self.imperialUnitsButton.layer.borderWidth = 1
            self.imperialUnitsButton.layer.borderColor = UIColor.red.cgColor
        }
        
        let unitsOfNotifications = UserDefaults.standard.value(forKey: "notifications") as? [Bool]
        self.stormButton.layer.borderWidth = 1
        self.rainButton.layer.borderWidth = 1
        self.snowButton.layer.borderWidth = 1
        self.stormButton.layer.borderColor = UIColor.clear.cgColor
        self.rainButton.layer.borderColor = UIColor.clear.cgColor
        self.snowButton.layer.borderColor = UIColor.clear.cgColor
        switch unitsOfNotifications {
        case [false, false, false]:
            self.stormButton.isSelected = false
            self.rainButton.isSelected = false
            self.snowButton.isSelected = false
            array[2] = self.snowButton.isSelected
            array[1] = self.rainButton.isSelected
            array[0] = self.stormButton.isSelected
        case [true, false, false]:
            self.stormButton.layer.borderColor = UIColor.red.cgColor
            self.stormButton.isSelected = true
            array[0] = self.stormButton.isSelected
        case [false, true, false]:
            self.rainButton.isSelected = true
            self.rainButton.layer.borderColor = UIColor.red.cgColor
            array[1] = self.rainButton.isSelected
        case [false, false, true]:
            self.snowButton.isSelected = true
            self.snowButton.layer.borderColor = UIColor.red.cgColor
            array[2] = self.snowButton.isSelected
        case [true, true, true]:
            self.stormButton.isSelected = true
            self.rainButton.isSelected = true
            self.snowButton.isSelected = true
            self.stormButton.layer.borderColor = UIColor.red.cgColor
            self.rainButton.layer.borderColor = UIColor.red.cgColor
            self.snowButton.layer.borderColor = UIColor.red.cgColor
            array[2] = self.snowButton.isSelected
            array[1] = self.rainButton.isSelected
            array[0] = self.stormButton.isSelected
        case [false, true, true]:
            self.rainButton.isSelected = true
            self.snowButton.isSelected = true
            self.rainButton.layer.borderColor = UIColor.red.cgColor
            self.snowButton.layer.borderColor = UIColor.red.cgColor
            array[2] = self.snowButton.isSelected
            array[1] = self.rainButton.isSelected
        case [true, false, true]:
            self.stormButton.isSelected = true
            self.snowButton.isSelected = true
            self.stormButton.layer.borderColor = UIColor.red.cgColor
            self.snowButton.layer.borderColor = UIColor.red.cgColor
            array[2] = self.snowButton.isSelected
            array[0] = self.stormButton.isSelected
        case [true, true, false]:
            self.stormButton.isSelected = true
            self.rainButton.isSelected = true
            self.stormButton.layer.borderColor = UIColor.red.cgColor
            self.rainButton.layer.borderColor = UIColor.red.cgColor
            array[1] = self.rainButton.isSelected
            array[0] = self.stormButton.isSelected
        default:
            self.stormButton.isSelected = true
            self.rainButton.isSelected = true
            self.snowButton.isSelected = true
            self.stormButton.layer.borderColor = UIColor.red.cgColor
            self.rainButton.layer.borderColor = UIColor.red.cgColor
            self.snowButton.layer.borderColor = UIColor.red.cgColor
            array[2] = self.snowButton.isSelected
            array[1] = self.rainButton.isSelected
            array[0] = self.stormButton.isSelected
        }
    }
    
    
    //MARK: - IBActions
    @IBAction func selectButtonPressed(_ sender: UIButton) {
        if sender == stormButton {
            self.stormButton.isSelected = !self.stormButton.isSelected
            self.stormButton.layer.borderColor = self.stormButton.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            self.stormButton.layer.borderWidth = 1
            array[0] = self.stormButton.isSelected
        } else if sender == rainButton {
            self.rainButton.isSelected = !self.rainButton.isSelected
            self.rainButton.layer.borderColor = self.rainButton.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            self.rainButton.layer.borderWidth = 1
            array[1] = self.rainButton.isSelected
        } else if sender == snowButton {
            self.snowButton.isSelected = !self.snowButton.isSelected
            self.snowButton.layer.borderColor = self.snowButton.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            self.snowButton.layer.borderWidth = 1
            array[2] = self.snowButton.isSelected
        }
    }
    
    @IBAction func timeButtonsPressed(_ sender: UIButton) {
        if sender == firstTimeButton {
            self.firstTimeButton.isSelected = !self.firstTimeButton.isSelected
            self.secondTimeButton.isSelected = false
            self.secondTimeButton.layer.borderColor = UIColor.clear.cgColor
            self.firstTimeButton.layer.borderWidth = 1
            self.firstTimeButton.layer.borderColor = self.firstTimeButton.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            UserDefaults.standard.set(true, forKey: "timeSetting")
        } else if sender == secondTimeButton {
            self.secondTimeButton.isSelected = !self.secondTimeButton.isSelected
            self.firstTimeButton.isSelected = false
            self.firstTimeButton.layer.borderColor = UIColor.clear.cgColor
            self.secondTimeButton.layer.borderWidth = 1
            self.secondTimeButton.layer.borderColor = self.secondTimeButton.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            UserDefaults.standard.set(false, forKey: "timeSetting")
        }
    }
    
    @IBAction func unitsButtonPressed(_ sender: UIButton) {
        if sender == metricUnitsButton {
            self.metricUnitsButton.isSelected = !self.metricUnitsButton.isSelected
            self.imperialUnitsButton.isSelected = false
            self.imperialUnitsButton.layer.borderColor = UIColor.clear.cgColor
            self.metricUnitsButton.layer.borderWidth = 1
            self.metricUnitsButton.layer.borderColor = self.metricUnitsButton.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            UserDefaults.standard.set(true, forKey: "isMetric")
        } else if sender == imperialUnitsButton {
            self.imperialUnitsButton.isSelected = !self.imperialUnitsButton.isSelected
            self.metricUnitsButton.isSelected = false
            self.metricUnitsButton.layer.borderColor = UIColor.clear.cgColor
            self.imperialUnitsButton.layer.borderWidth = 1
            self.imperialUnitsButton.layer.borderColor = self.imperialUnitsButton.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
            let value = imperialUnitsButton.isSelected ? false : true
            UserDefaults.standard.set(value, forKey: "isMetric")
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set(array, forKey: "notifications")
        NotificationCenter.default.post(name: .updateMainInterface, object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTimeButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: .updateMainInterface, object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveUnitsButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: .updateMainInterface, object: nil)
        navigationController?.popViewController(animated: true)
    }
}
