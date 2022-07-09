import Foundation
import UIKit

extension UIImageView {
    func getImageFromTheInternet(_ icon: String) {
        let endpoint = Endpoint.getIcon(icon: icon)
        var icon: Data?
        DispatchQueue.global(qos: .utility).async {
            guard let url = endpoint.url else { return }
            guard let iconData = try? Data(contentsOf: url) else { return }
            icon = iconData
            DispatchQueue.main.async {
                guard let icon = icon else { return }
                self.image = UIImage(data: icon)
            }
        }
    }
}
