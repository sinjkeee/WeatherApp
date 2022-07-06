import Foundation
import UIKit

extension UIImageView {
    func getImageFromTheInternet(_ icon: String) {
        let endpoint = Endpoint.getIcon(icon: icon)
        var icon: Data?
        DispatchQueue.global(qos: .utility).async {
            guard let iconData = try? Data(contentsOf: endpoint.url) else { fatalError() }
            icon = iconData
            DispatchQueue.main.async {
                guard let icon = icon else { return }
                self.image = UIImage(data: icon)
            }
        }
    }
}
