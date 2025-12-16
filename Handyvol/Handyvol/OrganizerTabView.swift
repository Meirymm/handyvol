import SwiftUI

struct OrganizerTabView: View {
    @EnvironmentObject var authManager: AuthStatusManager

    var body: some View {
        TabView {
            NavigationView {
                OrganizerEventsView()
            }
            .tabItem {
                Label(LocalizedStringKey("organizer_events"), systemImage: "calendar.badge.plus")
            }

            NavigationView {
                OrganizerApplicationsListView()
            }
            .tabItem {
                Label(LocalizedStringKey("volunteer_applications"), systemImage: "person.2.fill")
            }
            
            NavigationView {
                OrganizerProfileView()
            }
            .tabItem {
                Label(LocalizedStringKey("profile_tab"), systemImage: "person.crop.circle.fill")
            }
        }
    }
}

struct OrganizerApplicationsListView: View {
    @StateObject var organizerService = OrganizerService()
    
    var body: some View {
        List {
            if organizerService.organizerEvents.isEmpty {
                Text(LocalizedStringKey("no_events_created"))
                    .foregroundColor(.secondary)
            } else {
                ForEach(organizerService.organizerEvents) { event in
                    NavigationLink(destination: VolunteerApplicationsView(eventID: event.id ?? "", eventTitle: event.title)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("volunteer_applications"))
        .task {
            await organizerService.fetchOrganizerEvents()
        }
    }
}
