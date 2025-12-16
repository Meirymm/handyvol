import SwiftUI

struct AuthView: View {
    
    @ObservedObject var authManager: AuthStatusManager
    @StateObject private var authService = AuthService()
    
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    @State private var selectedRole = "volunteer"
    let roles = ["volunteer", "organizer"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isRegistering ? LocalizedStringKey("register_title") : LocalizedStringKey("login_button"))
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField(LocalizedStringKey("email_placeholder"), text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField(LocalizedStringKey("password_placeholder"), text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if isRegistering {
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey("role_picker_title"))
                            .font(.caption)
                        
                        Picker(LocalizedStringKey("role_picker_title"), selection: $selectedRole) {
                            ForEach(roles, id: \.self) { role in
                                Text(LocalizedStringKey("role_\(role)"))
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Button(action: {
                    if isRegistering {
                        Task {
                            await authService.registerUser(email: email,
                                                           password: password,
                                                           selectedRole: selectedRole)
                        }
                    } else {
                        Task {
                            await authService.loginUser(email: email, password: password)
                        }
                    }
                }) {
                    Text(isRegistering ? LocalizedStringKey("register_button") : LocalizedStringKey("login_button"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if let error = authService.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()

                Button(isRegistering ? LocalizedStringKey("have_account_prompt") : LocalizedStringKey("no_account_prompt")) {
                    withAnimation {
                        isRegistering.toggle()
                        authService.errorMessage = nil
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle(LocalizedStringKey("app_title"))
        }
    }
}
