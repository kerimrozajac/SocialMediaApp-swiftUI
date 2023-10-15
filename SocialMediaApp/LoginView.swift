//
//  LoginView.swift
//  SocialMediaApp
//
//  Created by Kerim Rozajac on 20. 3. 2023..
//

import SwiftUI


struct LoginView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @ObservedObject var authViewModel = AuthViewModel()
    @State private var loginError = false
    @State private var showAlert = false
    @State private var navigateToNextView = false
    @State private var alertMessage = "fail"
    @State private var loggedIn = false
    @State var isLoading: Bool = false
    
    
    
    var body: some View {
        VStack{
            
            
            
            Text("Log in")
                .font(.largeTitle)
                .padding()
            
            /*
             Image("logo")
             .resizable()
             .frame(width: 100, height: 100)
             .padding(.bottom, 40)
             */
            
            TextField("Username", text:$username)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                )
                .padding(.bottom, 20)
            
            SecureField("Password", text: $password)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                )
                .padding(.bottom, 20)
            
            
            /*
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
            */
            
            Button(action: loginTapped) {
                Text("Log in")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundColor(isLogInButtonDisabled ? .gray : .white)
                    .background(isLogInButtonDisabled ? Color.gray.opacity(0.2) : .green)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.2), lineWidth: 2))
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                
            }
            .disabled(isLogInButtonDisabled)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Login Result"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        
            
            
            Text("Don't have an account?")
                .foregroundColor(.blue)
                .padding(.top, 20)
            NavigationLink(destination: SignUpView()) {
                Text(" Click here to SignUp")
                    .foregroundColor(.red)
            }
            NavigationLink(destination: GreetingView(username: username), isActive: $loggedIn){
                EmptyView()
            }
            .hidden()
            
            Text("Forgot your password?")
                .foregroundColor(.blue)
                .padding(.top, 20)
            NavigationLink(destination: PasswordResetView()) {
                Text(" Click here to reset your password")
                    .foregroundColor(.red)
            }

            
            
        
        }
        .padding(.horizontal, 20)


    }
    
    var isLogInButtonDisabled: Bool {
        username.isEmpty || password.isEmpty
        }
    
    private func loginTapped() {
        self.isLoading = true
        authViewModel.loginUser(username: username, password: password) { success in
            if success {
                // Navigate to greeting view on successful login
                self.loggedIn = true
                print("loggin successfull", username, password)
                
            } else {
                // Show alert on unsuccessful login
                self.showAlert = true
                print("loggin unsuccessfull", username, password)
                self.alertMessage = authViewModel.errorMessage
            }
            
            
        }
        self.isLoading = false
    }
            

        
        
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

