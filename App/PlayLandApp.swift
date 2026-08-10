import SwiftUI

@main
struct PlayLandApp: App {
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
