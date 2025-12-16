//struct EventApplicationsView: View {
//    let event: Event
//    @StateObject private var organizerService = OrganizerService()
//    @State private var applications: [Application] = []
//    
//    var body: some View {
//        List {
//            if applications.isEmpty {
//                Text(LocalizedStringKey("no_applications"))
//                    .foregroundColor(.secondary)
//            } else {
//                ForEach(applications) { application in
//                    ApplicationRow(application: application, organizerService: organizerService)
//                }
//            }
//        }
//        .navigationTitle(event.title)
//        .refreshable {
//            await loadApplications()
//        }
//        .task {
//            await loadApplications()
//        }
//    }
//    
//    private func loadApplications() async {
//        applications = await organizerService.fetchApplicationsForEvent(eventID: event.id ?? "")
//    }
//}
