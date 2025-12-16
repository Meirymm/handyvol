import Foundation
import FirebaseAuth
import FirebaseFirestore


@MainActor
class AuthService: ObservableObject {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    @Published var errorMessage: String?
    
    func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        
        let number = ".*[0-9]+.*"
        let letter = ".*[a-zA-Z]+.*"
        let symbol = ".*[!@#$%^&*()\\-_=+\\|\\[{\\]};:'\",<.>/?]+.*"
        
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", number)
        let letterPredicate = NSPredicate(format: "SELF MATCHES %@", letter)
        let symbolPredicate = NSPredicate(format: "SELF MATCHES %@", symbol)
        
        return numberPredicate.evaluate(with: password) &&
               letterPredicate.evaluate(with: password) &&
               symbolPredicate.evaluate(with: password)
    }

    func registerUser(email: String, password: String, selectedRole: String) async {
        errorMessage = nil
        
        if !isValidPassword(password) {
            errorMessage = NSLocalizedString("password_safety_error", comment: "")
            return
        }
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            let userData: [String: Any] = [
                "email": email,
                "role": selectedRole,
                "createdAt": Timestamp(date: Date()),
                "mfa_enabled": false
            ]
            
            try await db.collection("users").document(uid).setData(userData)
            
        } catch {
            errorMessage = NSLocalizedString("registration_failed", comment: "") + ": \(error.localizedDescription)"
        }
    }
    
    func loginUser(email: String, password: String) async {
        errorMessage = nil
        
        do {
            _ = try await auth.signIn(withEmail: email, password: password)
        } catch {
            errorMessage = NSLocalizedString("login_failed", comment: "")
        }
    }
    
    func forceRefreshAuthToken() async {
        guard let user = auth.currentUser else { return }
        do {
            _ = try await user.getIDTokenResult(forcingRefresh: true)
        } catch {
            print("Ошибка при обновлении Auth Token: \(error)")
        }
    }
    
    func logout() {
        do {
            try auth.signOut()
            errorMessage = nil
        } catch {
            errorMessage = NSLocalizedString("logout_failed", comment: "") + ": \(error.localizedDescription)"
        }
    }
}
