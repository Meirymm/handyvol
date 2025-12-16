import SwiftUI

struct VolunteerApplicationsView: View {
    let eventID: String
    let eventTitle: String
    
    @StateObject var organizerService = OrganizerService()

    var body: some View {
        List {
            if organizerService.isLoading {
                ProgressView(LocalizedStringKey("loading"))
            } else if organizerService.applications.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text(LocalizedStringKey("no_applications_yet"))
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                ForEach(organizerService.applications.filter { $0.id != nil }, id: \.id!) { application in
                    ApplicationRow(application: application, organizerService: organizerService)
                }
            }
            
            if let error = organizerService.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            Task {
                await organizerService.fetchApplications(for: eventID)
            }
        }
        .refreshable {
            await organizerService.fetchApplications(for: eventID)
        }
        .navigationTitle(
            Text(NSLocalizedString("applications_for", comment: "") + " \(eventTitle)")
        )
    }
}

struct ApplicationRow: View {
    let application: Application
    @ObservedObject var organizerService: OrganizerService
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(application.volunteerEmail ?? NSLocalizedString("volunteer_data_private", comment: ""))
                .font(.headline)
            
            if let volunteerName = application.volunteerName, !volunteerName.isEmpty {
                Text(volunteerName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(LocalizedStringKey("applied_on"))
                Text(application.appliedAt, style: .date)
                Spacer()
                
                Text(application.status)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(5)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if application.status == "Pending" {
                HStack(spacing: 10) {
                    Button(LocalizedStringKey("accept_button")) {
                        Task {
                            await organizerService.updateApplicationStatus(
                                applicationID: application.id ?? "",
                                newStatus: "Approved"
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    Button(LocalizedStringKey("reject_button")) {
                        Task {
                            await organizerService.updateApplicationStatus(
                                applicationID: application.id ?? "",
                                newStatus: "Rejected"
                            )
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.top, 5)
            }
        }
        .padding(.vertical, 4)
    }
}
