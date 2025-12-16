import SwiftUI
import FirebaseAuth

struct AdminPanelView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var adminService = AdminService()
    
    var body: some View {
        TabView {
            NavigationView {
                UserModerationView(adminService: adminService)
            }
            .tabItem {
                Label(LocalizedStringKey("user_moderation"), systemImage: "person.3.fill")
            }
            
            NavigationView {
                EventModerationView(adminService: adminService)
            }
            .tabItem {
                Label(LocalizedStringKey("event_moderation"), systemImage: "calendar.badge.exclamationmark")
            }
            
            NavigationView {
                AdminStatsView()
            }
            .tabItem {
                Label(LocalizedStringKey("statistics"), systemImage: "chart.bar.fill")
            }
            
            NavigationView {
                AdminProfileView()
            }
            .tabItem {
                Label(LocalizedStringKey("profile"), systemImage: "person.circle.fill")
            }
        }
        .onAppear {
            Task {
                await authService.forceRefreshAuthToken()
                await adminService.fetchAllUsers()
            }
        }
    }
}
