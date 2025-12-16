import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class AdminService: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    @Published var errorMessage: String?
    @Published var users: [User] = []
    @Published var allEvents: [Event] = []
    

    struct User: Identifiable {
        let id: String
        let email: String
        var role: String
    }

    
    func fetchAllUsers() async {
        guard auth.currentUser?.uid != nil else { return }
            
        do {
            let snapshot = try await db.collection("users").getDocuments()
            self.users = snapshot.documents.compactMap { doc in
                let data = doc.data()
                return User(id: doc.documentID,
                            email: data["email"] as? String ?? "N/A",
                            role: data["role"] as? String ?? "volunteer")
            }
        } catch {
            self.errorMessage = "Ошибка загрузки пользователей: \(error.localizedDescription)"
        }
    }

    func updateUserRole(userID: String, newRole: String) async {
        guard auth.currentUser?.uid != nil else { return }
            
        do {
            try await db.collection("users").document(userID).updateData(["role": newRole])
                
            if let index = users.firstIndex(where: { $0.id == userID }) {
                users[index].role = newRole
            }
                
        } catch {
            self.errorMessage = "Ошибка обновления роли: \(error.localizedDescription)"
        }
    }

    
    func fetchAllEvents() async {
        self.errorMessage = nil
        
        do {
            let snapshot = try await db.collection("events")
                .order(by: "date", descending: true)
                .getDocuments()

            self.allEvents = snapshot.documents.compactMap { doc in
                return Event.fromDocument(doc)
            }
        } catch {
            self.errorMessage = "Ошибка загрузки всех мероприятий (Admin): \(error.localizedDescription)"
        }
    }
    
    func deleteEvent(eventID: String) async {
        self.errorMessage = nil
        
        do {
            let applicationsSnapshot = try await db.collection("applications")
                .whereField("eventID", isEqualTo: eventID)
                .getDocuments()
            
            let batch = db.batch()
            
            applicationsSnapshot.documents.forEach { doc in
                batch.deleteDocument(doc.reference)
            }
            
            let eventRef = db.collection("events").document(eventID)
            batch.deleteDocument(eventRef)
            
            try await batch.commit()
            
            allEvents.removeAll(where: { $0.id == eventID })
            
        } catch {
            self.errorMessage = "Ошибка удаления мероприятия: \(error.localizedDescription)"
        }
    }
}
