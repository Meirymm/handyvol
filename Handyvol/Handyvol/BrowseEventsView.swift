import SwiftUI



struct BrowseEventsView: View {
    @StateObject private var volunteerService = VolunteerService()
    
    @StateObject private var eventService = EventService()

    @State private var searchText: String = ""
    @State private var locationFilter: String = ""
    @State private var selectedTags: [String] = []
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    @State private var showFilters = true
    
    @State private var searchWorkItem: DispatchWorkItem?
    
    let availableTags = ["Ecology", "Social", "Education", "Health", "Animals", "Culture", "Sport"]

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText) {
                applyFilters()
            }
            .padding(.top, 5)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Filters").font(.subheadline).bold()
                    Spacer()
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: showFilters ? "chevron.up" : "chevron.down")
                    }
                }
                
                if showFilters {
                    TextField("Location (e.g. Astana)", text: $locationFilter)
                        .textFieldStyle(.roundedBorder)
                        
                    HStack {
                        Text("Tags:")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(availableTags, id: \.self) { tag in
                                    TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                        toggleTag(tag)
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text("Date:")
                        Spacer()
                        Button(showDatePicker ? formattedDate(selectedDate) : "Today & Future") {
                            showDatePicker.toggle()
                        }
                        .foregroundColor(.blue)
                    }
                    if showDatePicker {
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: selectedDate) { _ in
                                showDatePicker = false
                                applyFilters()
                            }
                    }
                    
                    Button("Apply Filters") {
                        applyFilters()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 5)
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, showFilters ? 10 : 0)

            Divider()

            contentView
        }
        .navigationTitle("Search")
        .onAppear {
            if eventService.events.isEmpty {
                applyFilters()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if eventService.isLoading {
            ProgressView("Loading Events...")
        } else if let error = eventService.errorMessage {
            Text(error).foregroundColor(.red).padding(.top, 50)
            if error.contains("requires an index") {
                Text("Необходимо создать индекс в консоли Firebase!").font(.caption).foregroundColor(.orange).padding(.horizontal)
            }
        } else if eventService.events.isEmpty {
             VStack {
                Image(systemName: "magnifyingglass.circle").font(.system(size: 60)).foregroundColor(.gray)
                Text("No events match your criteria.").foregroundColor(.gray)
             }
             .padding(.top, 50)
        } else {
            List(eventService.events, id: \.id) { event in
                NavigationLink {
                    EventDetailView(event: event, volunteerService: volunteerService) 
                } label: {
                    EventRow(event: event)
                }
            }
            .listStyle(.plain)
        }
    }
    

    func applyFilters() {
        
        let dateToFilter = showDatePicker ? selectedDate : nil
        
        eventService.fetchEvents(
            searchText: searchText.isEmpty ? nil : searchText,
            location: locationFilter.isEmpty ? nil : locationFilter,
            tags: selectedTags.isEmpty ? nil : selectedTags,
            date: dateToFilter
        )
    }
    
    func toggleTag(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
        applyFilters()
    }
    
    private func applyFiltersDebounced() {
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            self.applyFilters()
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: workItem)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
