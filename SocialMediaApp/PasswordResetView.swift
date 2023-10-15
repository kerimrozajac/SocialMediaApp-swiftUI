import SwiftUI

struct PasswordResetView: View {
    @State private var email = ""
    @State private var isPasswordResetEmailSent = false
    @ObservedObject var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            VStack{
                Text("Password Reset")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text:$email)
                    .disabled(isPasswordResetEmailSent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor(for: email), lineWidth: 2)
                    )
                    .padding(.bottom, 20)
                
                Button(action: resetPasswordTapped) {
                    Text(isPasswordResetEmailSent ? "Password reset email sent" : "Send password reset email")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .foregroundColor(isResetPasswordButtonDisabled ? .gray : .white)
                        .background(isResetPasswordButtonDisabled ? Color.gray.opacity(0.2) : .green)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.2), lineWidth: 2))
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                }
                .disabled(isResetPasswordButtonDisabled || isPasswordResetEmailSent)
            }
            .fixedSize(horizontal: false, vertical: true)
                
            if isPasswordResetEmailSent {
                Text("A password reset email has been sent to \(email)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                //.padding(.top, 40)
                    .padding(.bottom, 20)
                NavigationLink(destination: LoginView()) {
                    Text(" Click here to Log in")
                        .foregroundColor(.red)
                }
            }
            
        }
        .padding(.horizontal, 20)
    }
    
    private func resetPasswordTapped() {
        authViewModel.resetPassword(email: email) { success in
            if success {
                // Show success message or navigate to a success view
                print("Password reset email sent")
                isPasswordResetEmailSent = true
            } else {
                // Show error message
                print("Failed to reset password")
            }
        }
    }
    
    private func borderColor(for fieldValue: String) -> Color {
        if isPasswordResetEmailSent {
            return Color.gray.opacity(0.5)
        }
        else if fieldValue.isEmpty {
            return Color.gray.opacity(0.2) // Grey when not populated
        } else if fieldValueIsValid(fieldValue) {
            return Color.green // Green when valid
        } else {
            return Color.red // Red when invalid
        }
    }
    
    var isResetPasswordButtonDisabled: Bool {
            !(fieldValueIsValid(email)) || isPasswordResetEmailSent
        }
    
    private func fieldValueIsValid(_ fieldValue: String) -> Bool {
        
        // Validate email field
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: fieldValue)
        
    
    }
    
}
