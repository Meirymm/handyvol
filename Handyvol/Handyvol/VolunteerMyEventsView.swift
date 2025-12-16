import SwiftUI

struct VolunteerMyEventsView: View {
    
    @StateObject var volunteerService = VolunteerService()
    
    var body: some View {
        Group {
            if volunteerService.isLoading {
                ProgressView(LocalizedStringKey("loading_applications"))
            } else if let error = volunteerService.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if volunteerService.myApplications.isEmpty {
                Text(LocalizedStringKey("no_applications_yet"))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(volunteerService.myApplications) { application in
                        ApplicationRowForVolunteer(application: application)
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("my_applications"))
        .onAppear {
            Task {
                await volunteerService.fetchMyApplications()
            }
        }
        .refreshable {
             Task {
                await volunteerService.fetchMyApplications()
            }
        }
    }
}

struct ApplicationRowForVolunteer: View {
    let application: Application
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text(application.eventTitle)
                .font(.headline)
            
            HStack {
                Text(LocalizedStringKey("applied_on"))
                Text(application.appliedAt, style: .date)
                Spacer()
                
                StatusBadge(status: application.status)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}
