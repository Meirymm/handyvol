import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MainRouterView: View {
    
    @StateObject var authManager = AuthStatusManager()
        
        @State private var viewUpdateKey = UUID()
        
        var body: some View {
            Group {
                if !authManager.isAuthenticated {
                    AuthView(authManager: authManager)
                } else if authManager.userRole == nil {
                    ProgressView(LocalizedStringKey("loading_profile"))
                } else {
                    
                    NavigationView {
                        switch authManager.userRole {
                        case "admin":
                            AdminPanelView() 
                        case "organizer":
                            OrganizerTabView()
                        case "volunteer":
                            VolunteerTabView()
                        default:
                            VolunteerTabView()
                        }
                    }
                    .id(viewUpdateKey)
                }
            }
            .environmentObject(authManager)
        
        .environment(\.locale, LocalizationManager.shared.getCurrentLocale())
        
        .onReceive(NotificationCenter.default.publisher(for: .languageDidChange)) { _ in
            self.viewUpdateKey = UUID()
        }
    }
}
