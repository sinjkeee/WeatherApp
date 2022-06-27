import Foundation
import UIKit

extension UIImageView {
    func getImageFromTheInternet(_ icon: String) {
        let endpoint = Endpoint.getIcon(icon: icon)
        guard let iconData = try? Data(contentsOf: endpoint.url) else { fatalError() }
        let image = UIImage(data: iconData)
        self.image = image
    }
}
