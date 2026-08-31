import UIKit

enum ArtStudioColorMapping {
    static func uiColor(for id: String) -> UIColor {
        switch id {
        case "black": return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        case "white": return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case "gray": return UIColor.darkGray
        case "red": return UIColor.systemRed
        case "orange": return UIColor.systemOrange
        case "yellow": return UIColor.systemYellow
        case "green": return UIColor.systemGreen
        case "mint": return UIColor.systemMint
        case "cyan": return UIColor.systemCyan
        case "blue": return UIColor.systemBlue
        case "purple": return UIColor.systemPurple
        case "pink": return UIColor.systemPink
        case "brown": return UIColor.systemBrown
        default: return UIColor.black
        }
    }
}
