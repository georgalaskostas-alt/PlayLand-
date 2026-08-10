import SwiftUI

@main
struct PlayLandApp: App {
    @StateObject private var progressManager = ProgressViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(progressManager)
        }
    }
}
