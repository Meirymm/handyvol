import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VolunteerEventsService: ObservableObject {
    
    @Published var availableEvents: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func fetchAvailableEvents() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            defer { self.isLoading = false }
            
            let eventsRef = Firestore.firestore().collection("events")
            
            let query = eventsRef
                .whereField("date", isGreaterThan: Timestamp(date: Date()))
                .order(by: "date", descending: false)
            
            let snapshot = try await query.getDocuments()
            
            self.availableEvents = snapshot.documents.compactMap { doc -> Event? in
                var event = try? doc.data(as: Event.self)
                if event != nil {
                    event!.id = doc.documentID
                }
                return event
            }
            
        } catch {
            print("Error fetching available events: \(error.localizedDescription)")
            self.errorMessage = NSLocalizedString("error_loading_events", comment: "")
        }
    }
    
    func applyForEvent(event: Event) async -> Bool {
        guard let userID = currentUserID, let userEmail = Auth.auth().currentUser?.email else {
            self.errorMessage = NSLocalizedString("user_not_logged_in", comment: "")
            return false
        }
        
        self.errorMessage = nil
        
        let applicationData: [String: Any] = [
            "eventID": event.id ?? UUID().uuidString,
            "eventTitle": event.title,
            "volunteerID": userID,
            "volunteerEmail": userEmail,
            "status": "Pending",
            "appliedAt": Timestamp(date: Date())
        ]
        
        do {
            let db = Firestore.firestore()
            _ = try await db.collection("applications").addDocument(data: applicationData)
            
            return true
        } catch {
            print("Error applying for event: \(error.localizedDescription)")
            self.errorMessage = NSLocalizedString("application_failed", comment: "") + ": \(error.localizedDescription)"
            return false
        }
    }
}
