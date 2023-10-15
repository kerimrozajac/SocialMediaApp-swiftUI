//
//  EmailVerificationView.swift
//  SocialMediaApp
//
//  Created by Kerim Rozajac on 20. 5. 2023..
//

import SwiftUI

struct EmailVerificationView: View {
    let email: String
    
    var body: some View {
        VStack {
            Text("Check Your Email")
                .font(.largeTitle)
                .padding()
            
            Text("Please check your email (\(email)) to complete the registration process.")
                .font(.headline)
                .padding()
            
            Spacer()
        }
        .navigationBarTitle("Email Verification")
    }
}
