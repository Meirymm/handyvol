import Foundation
import UserNotifications
import UIKit

@MainActor
class NotificationService: ObservableObject {
    
    @Published var permissionGranted: Bool = false
    @Published var userPreferenceEnabled: Bool = false
    @Published var lastOperationStatus: String?
    
    private let notificationsEnabledKey = "NotificationsEnabled"
    
    init() {
        checkUserPreference()
        Task {
            await checkSystemNotificationStatus()
        }
    }
    
    func checkSystemNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let isAllowed = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        
        self.permissionGranted = isAllowed
        
        if settings.authorizationStatus == .denied {
            self.lastOperationStatus = "Системные уведомления отключены. Включите их в настройках iOS."
        } else if isAllowed {
            self.lastOperationStatus = "Разрешение на уведомления получено."
        }
    }
    
    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            
            self.permissionGranted = granted
            self.userPreferenceEnabled = granted
            self.setNotificationsPreference(isEnabled: granted)
            
            if granted {
                self.lastOperationStatus = "Разрешение получено. Регистрация для удаленных уведомлений..."
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                self.lastOperationStatus = "Разрешение отклонено пользователем."
            }
        } catch {
            self.lastOperationStatus = "Ошибка при запросе разрешения: \(error.localizedDescription)"
        }
    }
    
    func setNotificationsEnabled(isEnabled: Bool) {
        self.userPreferenceEnabled = isEnabled
        setNotificationsPreference(isEnabled: isEnabled)
        
        if isEnabled {
            Task {
                await requestNotificationPermission()
                await checkSystemNotificationStatus()
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            self.lastOperationStatus = "Локальные уведомления отключены."
        }
    }
    
    private func setNotificationsPreference(isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: notificationsEnabledKey)
    }
    
    private func checkUserPreference() {
        self.userPreferenceEnabled = UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }
    
    func sendTestNotification() {
        guard permissionGranted else {
            self.lastOperationStatus = "Разрешение на уведомления не получено."
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Тестовое уведомление"
        content.body = "Проверка: уведомления работают."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            Task { @MainActor in
                if let error = error {
                    self.lastOperationStatus = "Ошибка при отправке: \(error.localizedDescription)"
                } else {
                    self.lastOperationStatus = "Тестовое уведомление отправлено (сработает через 5 сек)."
                }
            }
        }
    }
}
