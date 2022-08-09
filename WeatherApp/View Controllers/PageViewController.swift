import UIKit

class PageViewController: UIPageViewController {
    
    private var controllers = [UIViewController]()
    private var navControllers = [UINavigationController]()
    private var cities = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cities = ["Москва"]
        
        createAndShowBlurEffectWithActivityIndicator()
        
        self.delegate = self
        self.dataSource = self
        
        for _ in cities {
            guard let firstvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "firstNavi") as? UINavigationController else { return }
            controllers.append(firstvc)
        }
        
        self.view.backgroundColor = .systemGray5
        self.setViewControllers([controllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    //MARK: - Methods
    func updateViewControllers(with weather: [WeatherData]) {
        self.navControllers.removeAll()
        for weatherForVC in weather {
            guard let firstvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "firstNavi") as? UINavigationController else { return }
            guard let vc = firstvc.viewControllers.first as? MainViewController else { return }
            vc.combiningMethods(weatherData: weatherForVC)
            vc.weatherForCitiesList = weather
            vc.updateCitiesTableView(with: weather)
            navControllers.append(firstvc)
        }
        
        hideBlurView()
        self.setViewControllers([navControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    private func createAndShowBlurEffectWithActivityIndicator() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        tabBarController?.view.addSubview(blurView)
        blurView.alpha = 1
        blurView.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview()
        }
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        blurView.contentView.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        activityIndicator.startAnimating()
    }
    
    private func hideBlurView() {
        var _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self = self,
                  let views = self.tabBarController?.view.subviews else { return }
            for view in views where view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        })
    }
}

//MARK: - extension PageViewController
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = navControllers.firstIndex(of: viewController as! UINavigationController) {
            if index > 0 {
                return navControllers[index - 1]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = navControllers.firstIndex(of: viewController as! UINavigationController) {
            if index < navControllers.count - 1 {
                return navControllers[index + 1]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return navControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
