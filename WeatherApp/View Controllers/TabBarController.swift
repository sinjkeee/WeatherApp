import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let second = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }
        guard let firstNavi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "firstNavi") as? UINavigationController else { return }
        guard let settingsNavi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsNavi") as? UINavigationController else { return }
        
        self.tabBar.backgroundColor = UIColor.clear
        self.setViewControllers([firstNavi, second, settingsNavi], animated: true)
        firstNavi.tabBarItem.title = "Main"
        firstNavi.tabBarItem.image = UIImage(systemName: "thermometer")
        second.tabBarItem.title = "Map".localized()
        second.tabBarItem.image = UIImage(systemName: "globe.europe.africa")
        settingsNavi.tabBarItem.title = "Settings".localized()
        settingsNavi.tabBarItem.image = UIImage(systemName: "gearshape")
        
    }
    
    
}
