//
//  ContentView.swift
//  SocialMediaApp
//
//  Created by Kerim Rozajac on 20. 3. 2023..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            List{
                Text("Content View")
                NavigationLink(destination: LoginView()) {
                    Text("Go to Login View")
                }
                NavigationLink(destination: SignUpView()) {
                    Text("Go to SignUP View")
                }
                NavigationLink(destination: PasswordResetView()) {
                    Text("Go to Password Reset View")
                }
                NavigationLink(destination: ChangePasswordView()) {
                    Text("Go to Change Password View")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
