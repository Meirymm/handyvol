import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class OrganizerService: ObservableObject {
    @Published var organizerEvents: [Event] = []
    @Published var applications: [Application] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    private func decodeEvent(from doc: DocumentSnapshot) -> Event? {
        return Event.fromDocument(doc)
    }
    
    func fetchOrganizerEvents() async {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = NSLocalizedString("user_not_authenticated", comment: "")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("events")
                .whereField("organizerID", isEqualTo: userID)
                .order(by: "date", descending: false)
                .getDocuments()
            
            self.organizerEvents = snapshot.documents.compactMap { doc in
                return decodeEvent(from: doc)
            }
            
            isLoading = false
        } catch {
            errorMessage = "Ошибка загрузки событий: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Create Event
    func createEvent(event: Event) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = NSLocalizedString("user_not_authenticated", comment: "")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let userDoc = try await db.collection("users").document(userID).getDocument()
            let userName = userDoc.data()?["email"] as? String ?? "Unknown"
            
            var newEvent = event
            newEvent.organizerID = userID
            newEvent.organizerName = userName
            
            let _ = try db.collection("events").addDocument(from: newEvent)
            
            isLoading = false
            await fetchOrganizerEvents()
            
        } catch {
            errorMessage = "Ошибка создания события: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Update Event
    func updateEvent(event: Event) async {
        guard let eventID = event.id else {
            errorMessage = "ID события не найден"
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = NSLocalizedString("user_not_authenticated", comment: "")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let eventDoc = try await db.collection("events").document(eventID).getDocument()
            guard let eventData = eventDoc.data(),
                    let organizerID = eventData["organizerID"] as? String,
                    organizerID == userID else {
                errorMessage = "У вас нет прав на редактирование этого события"
                isLoading = false
                return
            }
            
            try db.collection("events").document(eventID).setData(from: event, merge: true)
            
            isLoading = false
            await fetchOrganizerEvents()
            
        } catch {
            errorMessage = "Ошибка обновления события: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func deleteEvent(eventID: String) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = NSLocalizedString("user_not_authenticated", comment: "")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let eventDoc = try await db.collection("events").document(eventID).getDocument()
            guard let eventData = eventDoc.data(),
                    let organizerID = eventData["organizerID"] as? String,
                    organizerID == userID else {
                errorMessage = "У вас нет прав на удаление этого события"
                isLoading = false
                return
            }
            
            let applicationsSnapshot = try await db.collection("applications")
                .whereField("eventID", isEqualTo: eventID)
                .getDocuments()
            
            let batch = db.batch()
            
            for doc in applicationsSnapshot.documents {
                batch.deleteDocument(doc.reference)
            }
            
            batch.deleteDocument(db.collection("events").document(eventID))
            
            try await batch.commit()
            
            isLoading = false
            
        } catch {
            errorMessage = "Ошибка удаления события: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Fetch Applications for Event
    func fetchApplications(for eventID: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("applications")
                .whereField("eventID", isEqualTo: eventID)
                .getDocuments()
            
            applications = snapshot.documents.compactMap { doc in
                // Предполагается, что в Application.swift вы также присваиваете ID документа
                var application = try? doc.data(as: Application.self)
                application?.id = doc.documentID
                return application
            }
            
            isLoading = false
        } catch {
            errorMessage = "Ошибка загрузки заявок: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Update Application Status
    func updateApplicationStatus(applicationID: String, newStatus: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await db.collection("applications")
                .document(applicationID)
                .updateData(["status": newStatus])
            
            if let index = applications.firstIndex(where: { $0.id == applicationID }) {
                applications[index].status = newStatus
            }
            
            isLoading = false
        } catch {
            errorMessage = "Ошибка обновления статуса: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
