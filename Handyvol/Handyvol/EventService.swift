import Foundation
import FirebaseFirestore

class EventService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private func decodeEvent(from doc: DocumentSnapshot) -> Event? {
        
        return try? doc.data(as: Event.self)
    }
    
    func fetchEvents(searchText: String? = nil, location: String? = nil, tags: [String]? = nil, date: Date? = nil) {
        isLoading = true
        errorMessage = nil
        
        var query: Query = db.collection("events")
            .whereField("status", isEqualTo: "Open")
        
        // Фильтр по местоположению
        if let location = location, !location.isEmpty {
            query = query.whereField("location", isEqualTo: location)
        }
        
        // Фильтр по тегам
        if let tags = tags, !tags.isEmpty {
            query = query.whereField("tags", arrayContainsAny: tags)
        }
        
        // Фильтр по дате (только будущие события)
        if let date = date {
            let startOfDay = Calendar.current.startOfDay(for: date)
            query = query.whereField("date", isGreaterThanOrEqualTo: startOfDay)
        } else {
            query = query.whereField("date", isGreaterThanOrEqualTo: Date())
        }
        
        query = query.order(by: "date")
        
        query.getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Ошибка загрузки событий: \(error.localizedDescription)"
                    self?.events = []
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self?.events = []
                    return
                }
                
                // Декодирование
                let fetchedEvents = documents.compactMap { self?.decodeEvent(from: $0) }
                
                // Клиентский фильтр (поиск по тексту в title/description)
                if let searchText = searchText, !searchText.isEmpty {
                    self?.events = fetchedEvents.filter { event in
                        event.title.localizedCaseInsensitiveContains(searchText) ||
                        event.description.localizedCaseInsensitiveContains(searchText)
                    }
                } else {
                    self?.events = fetchedEvents
                }
                
                if self?.events.isEmpty == true && self?.errorMessage == nil {
                    self?.errorMessage = NSLocalizedString("no_events_found", comment: "")
                } else if self?.events.isEmpty == false {
                    self?.errorMessage = nil
                }
            }
        }
    }
}
