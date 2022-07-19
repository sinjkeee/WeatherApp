import Foundation

struct ReverseGeocoding: Codable {
    var name: String?
    var localNames: LocNames?
    var country: String?
    var state: String?
    
    enum CodingKeys: String, CodingKey {
        case name, country, state
        case localNames = "local_names"
    }
}

struct LocNames: Codable {
    var ru: String?
    var en: String?
    var featureName: String?
    
    enum CodingKeys: String, CodingKey {
        case ru, en
        case featureName = "feature_name"
    }
}
