import SwiftUI
import FirebaseAuth

struct OrganizerEventsView: View {
    @StateObject private var organizerService = OrganizerService()
    @State private var showCreateEvent = false
    @State private var selectedEvent: Event?
    @State private var showEditEvent = false
    @State private var showDeleteAlert = false
    @State private var eventToDelete: Event?
    
    var body: some View {
        NavigationView {
            Group {
                if organizerService.isLoading {
                    ProgressView(LocalizedStringKey("loading_events"))
                } else if let error = organizerService.errorMessage {
                    VStack(spacing: 16) {
                        Text("⚠️")
                            .font(.system(size: 50))
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button(LocalizedStringKey("retry_button")) {
                            Task {
                                await organizerService.fetchOrganizerEvents()
                            }
                        }
                    }
                    .padding()
                } else if organizerService.organizerEvents.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(LocalizedStringKey("no_events_yet"))
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Button(action: { showCreateEvent = true }) {
                            Label(LocalizedStringKey("create_first_event"), systemImage: "plus.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(organizerService.organizerEvents.filter { $0.id != nil }, id: \.id!) { event in
                            
                            NavigationLink {
                                VolunteerApplicationsView(eventID: event.id!, eventTitle: event.title)
                            } label: {
                                
                                OrganizerEventRow(
                                    event: event,
                                    onEdit: {
                                        selectedEvent = event
                                        showEditEvent = true
                                    },
                                    onDelete: {
                                        eventToDelete = event
                                        showDeleteAlert = true
                                    }
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(LocalizedStringKey("my_events"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateEvent = true }) {
                        Label(LocalizedStringKey("create_event"), systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateEvent) {
                CreateEventView()
                    .onDisappear {
                        Task {
                            await organizerService.fetchOrganizerEvents()
                        }
                    }
            }
            .sheet(isPresented: $showEditEvent) {
                if let event = selectedEvent {
                    EditEventView(event: event)
                        .onDisappear {
                            Task {
                                await organizerService.fetchOrganizerEvents()
                            }
                        }
                }
            }
            .alert(LocalizedStringKey("delete_event_confirmation"), isPresented: $showDeleteAlert) {
                Button(LocalizedStringKey("cancel_button"), role: .cancel) { }
                Button(LocalizedStringKey("delete_button"), role: .destructive) {
                    if let event = eventToDelete {
                        Task {
                            await organizerService.deleteEvent(eventID: event.id ?? "")
                            await organizerService.fetchOrganizerEvents()
                        }
                    }
                }
            } message: {
                Text(LocalizedStringKey("delete_event_message"))
            }
            .refreshable {
                await organizerService.fetchOrganizerEvents()
            }
            .task {
                await organizerService.fetchOrganizerEvents()
            }
        }
    }
}
