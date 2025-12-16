import SwiftUI

// --- Основной View ---

struct SearchView: View {
    
    @StateObject private var eventService = EventService()

    // Состояния для фильтров
    @State private var searchText: String = ""
    @State private var locationFilter: String = ""
    @State private var selectedTags: [String] = []
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    @State private var showFilters = true
    
    // Переменная для дебоунсинга (устраняет ошибку @objc)
    @State private var searchWorkItem: DispatchWorkItem?
    
    let availableTags = ["Ecology", "Social", "Education", "Health", "Animals", "Culture", "Sport"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Поле поиска
                SearchBar(text: $searchText) {
                    applyFilters()
                }
                .padding(.top, 5)

                // 2. Секция Фильтров
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Filters").font(.subheadline).bold()
                        Spacer()
                        Button(action: { showFilters.toggle() }) {
                            Image(systemName: showFilters ? "chevron.up" : "chevron.down")
                        }
                    }
                    
                    if showFilters {
                        // Фильтр по местоположению
                        TextField("Location (e.g. Astana)", text: $locationFilter)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: locationFilter) { _ in applyFiltersDebounced() }
                        
                        // Фильтр по тегам
                        HStack {
                            Text("Tags:")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(availableTags, id: \.self) { tag in
                                        // 💡 Предполагается, что TagButton доступен извне
                                        TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                            toggleTag(tag)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Фильтр по дате
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
                    }
                }
                .padding([.horizontal, .top])
                .padding(.bottom, showFilters ? 10 : 0)

                Divider()

                // 3. Результаты
                contentView
            }
            .navigationTitle("Search")
            .onAppear {
                if eventService.events.isEmpty {
                    applyFilters()
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if eventService.isLoading {
            ProgressView("Loading Events...")
        } else if let error = eventService.errorMessage {
            Text(error).foregroundColor(.red).padding(.top, 50)
        } else if eventService.events.isEmpty {
             VStack {
                Image(systemName: "magnifyingglass.circle").font(.system(size: 60)).foregroundColor(.gray)
                Text("No events match your criteria.").foregroundColor(.gray)
             }
             .padding(.top, 50)
        } else {
            List(eventService.events, id: \.id) { event in
                NavigationLink {
                    // Здесь должна быть ваша DetailView
                    Text("Detail View for \(event.title)")
                } label: {
                    // 💡 ИСПОЛЬЗУЕТСЯ ВАШ EventRow
                    EventRow(event: event)
                }
            }
            .listStyle(.plain)
        }
    }
    
    // --- Логика фильтрации и дебоунсинг ---

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
    
    // НОВЫЙ ДЕБОУНСИНГ с DispatchWorkItem
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
