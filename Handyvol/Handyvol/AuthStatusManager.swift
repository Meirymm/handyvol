import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthStatusManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userRole: String? = nil
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()

    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                self.isAuthenticated = true
                self.fetchUserRole(uid: user.uid)
            } else {
                self.isAuthenticated = false
                self.userRole = nil
            }
        }
    }

    private func fetchUserRole(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user role: \(error.localizedDescription)")
                self.userRole = "volunteer"
                return
            }
            
            if let data = snapshot?.data(), let role = data["role"] as? String {
                self.userRole = role
            } else {
                self.userRole = "volunteer"
            }
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
