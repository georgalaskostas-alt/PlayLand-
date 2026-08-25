import SwiftUI

@main
struct PlayLandApp: App {
    @UIApplicationDelegateAdaptor(PlayLandAppDelegate.self) private var appDelegate
    @StateObject private var progressManager = ProgressViewModel()
    @StateObject private var appSettings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(progressManager)
                .environmentObject(appSettings)
                .environment(\.locale, appSettings.locale)
        }
    }
}
