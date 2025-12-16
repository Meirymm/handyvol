import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class VolunteerService: ObservableObject {

    @Published var myApplications: [Application] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func hasApplied(for eventID: String) -> Bool {
        guard let userID = currentUserID else { return false }
        return myApplications.contains(where: { $0.eventID == eventID && $0.volunteerID == userID })
    }
    
    func applyForEvent(event: Event) async {
        guard let userID = currentUserID, let userEmail = Auth.auth().currentUser?.email else {
            self.errorMessage = NSLocalizedString("user_not_logged_in", comment: "")
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        if hasApplied(for: event.id ?? "") {
            self.errorMessage = NSLocalizedString("application_already_submitted", comment: "")
            self.isLoading = false
            return
        }
        
        let applicationData: [String: Any] = [
            "eventID": event.id ?? "",
            "eventTitle": event.title,
            "volunteerID": userID,
            "volunteerEmail": userEmail,
            "status": "Pending",
            "appliedAt": Timestamp(date: Date())
        ]
        
        do {
            defer { self.isLoading = false }
            
            let db = Firestore.firestore()
            let docRef = try await db.collection("applications").addDocument(data: applicationData)
            
            if let newApplication = try? await db.collection("applications").document(docRef.documentID).getDocument().data(as: Application.self) {
                var appWithID = newApplication
                appWithID.id = docRef.documentID
                self.myApplications.insert(appWithID, at: 0)
                self.errorMessage = nil
            }

        } catch {
            print("Error creating application: \(error.localizedDescription)")
            self.errorMessage = NSLocalizedString("error_creating_application", comment: "")
        }
    }

    func fetchMyApplications() async {
        guard let userID = currentUserID else {
            self.myApplications = []
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        do {
            defer { self.isLoading = false }

            let applicationsRef = Firestore.firestore().collection("applications")
            let query = applicationsRef
                .whereField("volunteerID", isEqualTo: userID)
                .order(by: "appliedAt", descending: true)

            let snapshot = try await query.getDocuments()

            self.myApplications = snapshot.documents.compactMap { doc in
                var application = try? doc.data(as: Application.self)
                if application != nil {
                    application!.id = doc.documentID
                }
                return application
            }
            self.errorMessage = nil 

        } catch {
            print("Error fetching volunteer applications: \(error.localizedDescription)")
            self.errorMessage = NSLocalizedString("error_loading_applications", comment: "")
        }
    }
}
