import SwiftUI
import FirebaseAuth

struct UserModerationView: View {
    @ObservedObject var adminService: AdminService
    
    var body: some View {
        List {
            if let error = adminService.errorMessage {
                Section {
                    Text("Ошибка: \(error)")
                        .foregroundColor(.red)
                }
            } else if adminService.users.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("no_users_found"))
                            .foregroundColor(.secondary)
                        Text(LocalizedStringKey("pull_to_refresh"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            } else {
                Section {
                    ForEach(adminService.users) { user in
                        UserRowView(user: user, adminService: adminService)
                    }
                } header: {
                    HStack(spacing: 4) {
                        Text(LocalizedStringKey("all_users_title"))
                        Text("(\(adminService.users.count))")
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("user_moderation_title"))
        .refreshable {
            await adminService.fetchAllUsers()
        }
        .task {
            if adminService.users.isEmpty {
                await adminService.fetchAllUsers()
            }
        }
    }
    
    private func roleColor(_ role: String) -> Color {
        switch role {
        case "admin": return .red
        case "organizer": return .orange
        default: return .green
        }
    }
}

struct UserRowView: View {
    var user: AdminService.User
    @ObservedObject var adminService: AdminService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(user.email)
                .font(.headline)
            
            HStack(spacing: 4) {
                Text(LocalizedStringKey("role"))
                Text(":")
                
                Text(user.role.capitalized)
                    .fontWeight(.semibold)
                    .foregroundColor(roleColor(user.role))
            }
            .font(.subheadline)
            
            if user.id != Auth.auth().currentUser?.uid {
                Menu {
                    Button {
                        Task {
                            await adminService.updateUserRole(userID: user.id, newRole: "volunteer")
                        }
                    } label: {
                        Label(LocalizedStringKey("role_volunteer"), systemImage: "hand.raised.fill")
                    }
                    
                    Button {
                        Task {
                            await adminService.updateUserRole(userID: user.id, newRole: "organizer")
                        }
                    } label: {
                        Label(LocalizedStringKey("role_organizer"), systemImage: "briefcase.fill")
                    }
                } label: {
                    Text(LocalizedStringKey("change_role_button"))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            } else {
                Text(LocalizedStringKey("role_cannot_be_changed"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func roleColor(_ role: String) -> Color {
        switch role {
        case "admin": return .red
        case "organizer": return .orange
        default: return .green
        }
    }
}
