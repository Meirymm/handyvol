import SwiftUI

struct EventSearchView: View {
    
    @StateObject var eventService = EventService()
    
    @State private var searchText = ""
    @State private var selectedLocation = ""
    @State private var selectedTags: [String] = []
    @State private var showFilters = false
    
    let availableTags = ["ecology", "children", "sport", "education", "health", "culture"]

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText) {
                    
                    eventService.fetchEvents(location: selectedLocation.isEmpty ? nil : selectedLocation, tags: selectedTags.isEmpty ? nil : selectedTags)
                }
                
                if eventService.isLoading {
                    ProgressView(LocalizedStringKey("loading_events"))
                } else if let error = eventService.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(eventService.events.filter { event in
                        searchText.isEmpty || event.title.localizedCaseInsensitiveContains(searchText)
                    }) { event in
                        EventRow(event: event)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(LocalizedStringKey("search_events"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters.toggle() }) {
                        Label(LocalizedStringKey("filters_button"), systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(
                    selectedLocation: $selectedLocation,
                    selectedTags: $selectedTags,
                    availableTags: availableTags,
                    onApply: {
                        eventService.fetchEvents(location: selectedLocation.isEmpty ? nil : selectedLocation, tags: selectedTags.isEmpty ? nil : selectedTags)
                        showFilters = false
                    }
                )
            }
            .onAppear {
                if eventService.events.isEmpty {
                    eventService.fetchEvents()
                }
            }
        }
    }
}
