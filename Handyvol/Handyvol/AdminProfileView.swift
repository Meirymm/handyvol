import SwiftUI
import FirebaseAuth

struct AdminProfileView: View {
    @EnvironmentObject var authManager: AuthStatusManager
    @StateObject private var authService = AuthService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var adminService = AdminService()
    @ObservedObject var localizationManager = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            Form {
                accountSettingsSection
                notificationSettingsSection
            }
            .navigationTitle(LocalizedStringKey("admin_panel_title"))
            .task {
                await notificationService.checkSystemNotificationStatus()
            }
        }
    }
    
    private var accountSettingsSection: some View {
        Section {
            accountInfoRow
            languagePicker
            manageUsersLink
            statisticsLink
            logoutButton
        } header: {
            Text(LocalizedStringKey("account_settings"))
        }
    }
    
    private var accountInfoRow: some View {
        HStack {
            Text(LocalizedStringKey("logged_in_as"))
            Spacer()
            Text("Admin: \(Auth.auth().currentUser?.email ?? "N/A")")
                .foregroundColor(.red)
        }
    }
    
    private var languagePicker: some View {
        Picker(
            LocalizedStringKey("language_select_label"),
            selection: $localizationManager.currentLanguageCode
        ) {
            ForEach(localizationManager.availableLanguages, id: \.0) { code, name in
                Text(name).tag(code)
            }
        }
        .onChange(of: localizationManager.currentLanguageCode) { _, newCode in
            localizationManager.setLanguage(langCode: newCode)
        }
    }
    
    private var manageUsersLink: some View {
        NavigationLink {
            UserModerationView(adminService: adminService)
        } label: {
            Text(LocalizedStringKey("manage_users"))
        }
    }
    
    private var statisticsLink: some View {
        NavigationLink {
            AdminStatsView()
        } label: {
            Text(LocalizedStringKey("view_statistics"))
        }
    }
    
    private var logoutButton: some View {
        Button {
            authService.logout()
        } label: {
            Text(LocalizedStringKey("logout_button"))
                .foregroundColor(.red)
        }
    }
    
    private var notificationSettingsSection: some View {
        Section {
            notificationToggle
            permissionStatusRow
            requestPermissionButton
            testNotificationButton
            operationStatusText
        } header: {
            Text(LocalizedStringKey("notification_settings"))
        }
    }
    
    private var notificationToggle: some View {
        Toggle(
            LocalizedStringKey("receive_notifications_toggle"),
            isOn: $notificationService.userPreferenceEnabled
        )
        .onChange(of: notificationService.userPreferenceEnabled) { _, newValue in
            notificationService.setNotificationsEnabled(isEnabled: newValue)
        }
    }
    
    private var permissionStatusRow: some View {
        HStack {
            Text(LocalizedStringKey("system_permission_status"))
            Spacer()
            Text(
                notificationService.permissionGranted
                    ? LocalizedStringKey("granted")
                    : LocalizedStringKey("denied_or_not_requested")
            )
            .foregroundColor(notificationService.permissionGranted ? .green : .orange)
        }
    }
    
    private var requestPermissionButton: some View {
        Button {
            Task {
                await notificationService.requestNotificationPermission()
            }
        } label: {
            Text(LocalizedStringKey("request_notifications_permission"))
        }
        .disabled(notificationService.permissionGranted)
    }
    
    private var testNotificationButton: some View {
        Button {
            notificationService.sendTestNotification()
        } label: {
            Text(LocalizedStringKey("send_test_notification"))
        }
        .disabled(!notificationService.permissionGranted)
    }
    
    @ViewBuilder
    private var operationStatusText: some View {
        if let status = notificationService.lastOperationStatus {
            Text(status)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
