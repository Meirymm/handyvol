import SwiftUI
import FirebaseAuth

struct VolunteerProfileView: View {
    @EnvironmentObject var authManager: AuthStatusManager
    @StateObject private var authService = AuthService()
    @StateObject private var notificationService = NotificationService()
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationStack {
            Form {
                accountSettingsSection
                notificationSettingsSection
            }
            .navigationTitle(LocalizedStringKey("volunteer_profile_title"))
            .task {
                await notificationService.checkSystemNotificationStatus()
            }
        }
    }
    
    private var accountSettingsSection: some View {
        Section {
            accountInfoRow
            languagePicker
            logoutButton
        } header: {
            Text(LocalizedStringKey("account_settings"))
        }
    }
    
    private var accountInfoRow: some View {
        HStack {
            Text(LocalizedStringKey("logged_in_as"))
            Spacer()
            Text("Volunteer: \(Auth.auth().currentUser?.email ?? "N/A")")
                .foregroundColor(.green)
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
}
