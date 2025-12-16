import SwiftUI

struct EventModerationView: View {
    @StateObject var adminService = AdminService()
    
    var body: some View {
        NavigationView {
            List {
                Section("Все Мероприятия (\(adminService.allEvents.count))") {
                    ForEach(adminService.allEvents) { event in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                Text("Организатор: \(event.organizerName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Button(role: .destructive, action: {
                                Task {
                                    await adminService.deleteEvent(eventID: event.id ?? "")
                                }
                            }) {
                                Image(systemName: "trash").foregroundColor(.red)
                            }
                        }
                    }
                }
                
                if let error = adminService.errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationTitle(LocalizedStringKey("event_moderation"))
            .onAppear {
                Task {
                    await adminService.fetchAllEvents()
                }
            }
            .refreshable {
                await adminService.fetchAllEvents()
            }
        }
    }
}
