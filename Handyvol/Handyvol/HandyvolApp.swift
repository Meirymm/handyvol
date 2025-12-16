import SwiftUI
import FirebaseCore

@main
struct HandyvolApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainRouterView()
        }
    }
}
