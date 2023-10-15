import SwiftUI

struct GreetingView: View {
    
    let username: String
    
    @ObservedObject var authViewModel = AuthViewModel()
    @State private var showAlert = false
    @State private var loggedOut = false
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Text("Welcome, \(username)!")
                .font(.headline)
                .padding()
            
            if isLoading {
                ProgressView()
            } else {
                Button(action: logoutTapped) {
                    Text("Log Out")
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }
                .padding()
            }
            NavigationLink(destination: LoginView(), isActive: $loggedOut){
                EmptyView()
            }
            .hidden()
            
            
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Log out"),
                message: Text(authViewModel.error ?? "Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Cancel")) {
                    // handle cancel action here
                    showAlert = false
                },
                secondaryButton: .default(Text("Log out")) {
                    
                    isLoading = true
                    authViewModel.logoutUser()
                    loggedOut = true
                }
            )
        }
        
        NavigationLink(destination: ChangePasswordView()) {
            Text("Change password")
                .foregroundColor(.red)
        }
        
    }
    
    private func logoutTapped() {
        showAlert = true
        
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView(username: "placeholder")
    }
}
