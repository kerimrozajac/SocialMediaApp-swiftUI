import SwiftUI
import Alamofire

struct ChangePasswordView: View {
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @ObservedObject private var authViewModel = AuthViewModel()

    var body: some View {
        VStack {
            SecureField("New Password", text: $newPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: changePassword) {
                Text("Change Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .disabled(!passwordsMatch() || newPassword.isEmpty || confirmPassword.isEmpty)
            //.alert(isPresented: $authViewModel.wrappedValue.showError) {
            //    Alert(title: Text("Error"), message: Text(authViewModel.errorMessage))
            //}
        }
        .navigationBarTitle("Change Password")
    }
    
    private func changePassword() {
        authViewModel.changePassword(newPassword: newPassword) { success, error in
            if success {
                // Password changed successfully
                print("Password changed successfully")
            } else {
                // Error occurred during password change
                if let error = error {
                    print("Password change failed: \(error.localizedDescription)")
                } else {
                    print("Password change failed")
                }
            }
        }
    }
    
    private func passwordsMatch() -> Bool {
        return newPassword == confirmPassword
    }
}
