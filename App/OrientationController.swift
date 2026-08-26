import SwiftUI
import UIKit

final class PlayLandAppDelegate: NSObject, UIApplicationDelegate {
    static var orientationMask: UIInterfaceOrientationMask = .allButUpsideDown

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Self.orientationMask
    }
}

@MainActor
enum OrientationController {
    static func allowAll() {
        apply(mask: .allButUpsideDown, preferences: nil)
    }

    static func requireLandscape() {
        apply(mask: .landscape, preferences: .landscape)
    }

    private static func apply(mask: UIInterfaceOrientationMask, preferences: UIInterfaceOrientationMask?) {
        PlayLandAppDelegate.orientationMask = mask

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return
        }

        scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()

        guard let preferences else { return }

        if #available(iOS 16.0, *) {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: preferences)
            scene.requestGeometryUpdate(geometryPreferences) { error in
                print("Orientation update failed: \(error.localizedDescription)")
            }
        }
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first(where: { $0.isKeyWindow })
    }
}
