//struct ApplicationRow: View {
//    let application: Application
//    @ObservedObject var organizerService: OrganizerService
//    
//    var statusColor: Color {
//        switch application.status {
//        case "Approved": return .green
//        case "Rejected": return .red
//        default: return .orange
//        }
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(application.volunteerName)
//                .font(.headline)
//            
//            Text(application.volunteerEmail)
//                .font(.caption)
//                .foregroundColor(.secondary)
//            
//            HStack {
//                Text(LocalizedStringKey("status"))
//                    .font(.caption)
//                Text(application.status)
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundColor(statusColor)
//            }
//            
//            if application.status == "Pending" {
//                HStack(spacing: 12) {
//                    Button(LocalizedStringKey("approve_button")) {
//                        Task {
//                            await organizerService.updateApplicationStatus(
//                                applicationID: application.id ?? "",
//                                newStatus: "Approved"
//                            )
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.green)
//                    
//                    Button(LocalizedStringKey("reject_button")) {
//                        Task {
//                            await organizerService.updateApplicationStatus(
//                                applicationID: application.id ?? "",
//                                newStatus: "Rejected"
//                            )
//                        }
//                    }
//                    .buttonStyle(.bordered)
//                    .tint(.red)
//                }
//                .font(.caption)
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
