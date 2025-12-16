import SwiftUI
import FirebaseFirestore

struct AdminStatsView: View {
    @StateObject private var adminService = AdminService()
    @State private var stats = Stats()
    
    struct Stats {
        var totalUsers = 0
        var totalEvents = 0
        var totalApplications = 0
        var adminCount = 0
        var organizerCount = 0
        var volunteerCount = 0
        var pendingApplications = 0
        var approvedApplications = 0
    }
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("user_statistics"))) {
                StatRow(title: LocalizedStringKey("total_users"), value: "\(stats.totalUsers)", icon: "person.3.fill", color: .blue)
                StatRow(title: LocalizedStringKey("admins"), value: "\(stats.adminCount)", icon: "shield.fill", color: .red)
                StatRow(title: LocalizedStringKey("organizers"), value: "\(stats.organizerCount)", icon: "briefcase.fill", color: .orange)
                StatRow(title: LocalizedStringKey("volunteers"), value: "\(stats.volunteerCount)", icon: "hand.raised.fill", color: .green)
            }
            
            Section(header: Text(LocalizedStringKey("event_statistics"))) {
                StatRow(title: LocalizedStringKey("total_events"), value: "\(stats.totalEvents)", icon: "calendar.badge.plus", color: .purple)
            }
            
            Section(header: Text(LocalizedStringKey("application_statistics"))) {
                StatRow(title: LocalizedStringKey("total_applications"), value: "\(stats.totalApplications)", icon: "doc.fill", color: .indigo)
                StatRow(title: LocalizedStringKey("pending_applications"), value: "\(stats.pendingApplications)", icon: "clock.fill", color: .yellow)
                StatRow(title: LocalizedStringKey("approved_applications"), value: "\(stats.approvedApplications)", icon: "checkmark.circle.fill", color: .green)
            }
            
            if let error = adminService.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle(LocalizedStringKey("statistics"))
        .refreshable {
            await loadStats()
        }
        .task {
            await loadStats()
        }
    }
    
    private func loadStats() async {
        let db = Firestore.firestore()
        
        do {
            // Загружаем пользователей
            let usersSnapshot = try await db.collection("users").getDocuments()
            stats.totalUsers = usersSnapshot.documents.count
            
            stats.adminCount = usersSnapshot.documents.filter { ($0.data()["role"] as? String) == "admin" }.count
            stats.organizerCount = usersSnapshot.documents.filter { ($0.data()["role"] as? String) == "organizer" }.count
            stats.volunteerCount = usersSnapshot.documents.filter { ($0.data()["role"] as? String) == "volunteer" }.count
            
            // Загружаем события
            let eventsSnapshot = try await db.collection("events").getDocuments()
            stats.totalEvents = eventsSnapshot.documents.count
            
            // Загружаем заявки
            let applicationsSnapshot = try await db.collection("applications").getDocuments()
            stats.totalApplications = applicationsSnapshot.documents.count
            
            stats.pendingApplications = applicationsSnapshot.documents.filter { ($0.data()["status"] as? String) == "Pending" }.count
            stats.approvedApplications = applicationsSnapshot.documents.filter { ($0.data()["status"] as? String) == "Approved" }.count
            
        } catch {
            adminService.errorMessage = "Ошибка загрузки статистики: \(error.localizedDescription)"
        }
    }
}

struct StatRow: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
