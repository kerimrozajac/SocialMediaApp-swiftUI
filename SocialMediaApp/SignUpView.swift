//
//  SignUpView.swift
//  SocialMediaApp
//
//  Created by Kerim Rozajac on 20. 3. 2023..
//

import SwiftUI

struct SignUpView: View {
    
    // TODO: dodati email verifikaciju registracije
    // TODO: dodati setup 2way login authentikacije sa nekim SMS gatewayom
    
    @State private var username = ""
    @State private var email = ""
    @State private var password1 = ""
    @State private var password2 = ""
    @State private var signupError = false
    @State private var showSuccessScreen = false
    @State private var alertMessage = "fail"
    @ObservedObject var authViewModel = AuthViewModel()
    @State private var showEmailVerificationView = false
    
    var body: some View {
        VStack{
            Text("Sign Up")
                .font(.largeTitle)
                .padding()
            
            TextField("Username", text:$username)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor(for: username, fieldType: .username), lineWidth: 2)
                        )
                .padding(.bottom, 20)
                 
            
            TextField("Email", text:$email)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor(for: email, fieldType: .email), lineWidth: 2)
                        )
                .padding(.bottom, 20)
            
            SecureField("Password", text: $password1)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor(for: password1, fieldType: .password1), lineWidth: 2)
                        )
                .padding(.bottom, 20)
            
            SecureField("Retype password", text: $password2)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor(for: password2, fieldType: .password2), lineWidth: 2)
                        )
                .padding(.bottom, 20)
            
            NavigationLink(destination: EmailVerificationView(email: email), isActive: $showEmailVerificationView) {
                EmptyView()
            }
            Button(action: signUpTapped) {
                Text("Sign Up")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundColor(isSignUpButtonDisabled ? .gray : .white)
                    .background(isSignUpButtonDisabled ? Color.gray.opacity(0.2) : .green)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.2), lineWidth: 2))
                    .padding(.top, 30)
                    .padding(.bottom, 20)
            }
            .disabled(isSignUpButtonDisabled)
            .alert(isPresented: $signupError) {
                Alert(
                    title: Text("Sign Up failed"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            
            Text("Already have an account?")
                .foregroundColor(.blue)
                .padding(.horizontal, 20)

            NavigationLink(destination: LoginView()) {
                Text(" Click here to Log in")
                    .foregroundColor(.red)
            }
            Spacer()
            
        }
        .padding(.horizontal, 20)
        
    }
    
    private func signUpTapped() {
        authViewModel.registerUser(username: username, email: email, password1: password1, password2: password2) {
            success in
            if success {
                // Navigate to "check your email to register your account" view
                showEmailVerificationView = true
                print("registration successfull")

                
            } else {
                // Show alert on unsuccessful login
                self.signupError = true
                print("registration unsuccessfull", username, password1, password2)
                alertMessage = authViewModel.errorMessage
            }
        }
         
    }
    
    private func borderColor(for fieldValue: String, fieldType: FieldType) -> Color {
            if fieldValue.isEmpty {
                return Color.gray.opacity(0.2) // Grey when not populated
            } else if fieldValueIsValid(fieldValue, fieldType: fieldType) {
                return Color.green // Green when valid
            } else {
                return Color.red // Red when invalid
            }
        }
    
    enum FieldType {
        case email
        case password1
        case password2
        case username
    }
    
    private func fieldValueIsValid(_ fieldValue: String, fieldType: FieldType) -> Bool {
        switch fieldType {
            case .email:
                // Validate email field
                let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: fieldValue)
            case .password2:
                // Check if password1 and password2 match
                return fieldValue == password1
            case .password1:
                // Validate password field
                let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~`!@#$%^&*()_-+={[}]|\\:;\'\"<,>.?/")
                // Check if password1 is at least 8 characters long
                return fieldValue.count >= 8 && fieldValue.rangeOfCharacter(from: allowedCharacters.inverted) == nil
            case .username:
                // Validate username field
                let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@.+_-")
                return fieldValue.rangeOfCharacter(from: allowedCharacters.inverted) == nil
            }
    }
    
    var isSignUpButtonDisabled: Bool {
            !(fieldValueIsValid(username, fieldType: .username) &&
              fieldValueIsValid(email, fieldType: .email) &&
              fieldValueIsValid(password1, fieldType: .password1) &&
              fieldValueIsValid(password2, fieldType: .password2))
        }
    
    
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}


