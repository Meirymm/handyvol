import SwiftUI

struct VolunteerTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                VolunteerMyEventsView()
            }
            .tabItem {
                Label(LocalizedStringKey("my_events_tab"), systemImage: "calendar.badge.checkmark")
            }

            NavigationView {
                BrowseEventsView()
            }
            .tabItem {
                Label(LocalizedStringKey("browse_events_tab"), systemImage: "magnifyingglass")
            }
            
            NavigationView {
                NotificationsView()
            }
            .tabItem {
                Label(LocalizedStringKey("notifications_tab"), systemImage: "bell.fill")
            }

            NavigationView {
                VolunteerProfileView()
            }
            .tabItem {
                Label(LocalizedStringKey("profile_tab"), systemImage: "person.crop.circle.fill")
            }
        }
    }
}

struct NotificationsView: View {
    @StateObject private var notificationService = NotificationService()
    
    var body: some View {
        List {
            Section {
                Toggle(LocalizedStringKey("receive_notifications_toggle"), isOn: $notificationService.userPreferenceEnabled)
                    .onChange(of: notificationService.userPreferenceEnabled) { _, newValue in
                        notificationService.setNotificationsEnabled(isEnabled: newValue)
                    }
                
                HStack {
                    Text(LocalizedStringKey("system_permission_status"))
                    Spacer()
                    Text(notificationService.permissionGranted ? LocalizedStringKey("granted") : LocalizedStringKey("denied_or_not_requested"))
                        .foregroundColor(notificationService.permissionGranted ? .green : .orange)
                }
                
                Button(LocalizedStringKey("send_test_notification")) {
                    notificationService.sendTestNotification()
                }
                .disabled(!notificationService.permissionGranted)
                
                if let status = notificationService.lastOperationStatus {
                    Text(status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text(LocalizedStringKey("notification_settings"))
            }
            
            Section {
                Text(LocalizedStringKey("no_notifications_yet"))
                    .foregroundColor(.secondary)
            } header: {
                Text(LocalizedStringKey("recent_notifications"))
            }
        }
        .navigationTitle(LocalizedStringKey("notifications_tab"))
        .task {
            await notificationService.checkSystemNotificationStatus()
        }
    }
}
