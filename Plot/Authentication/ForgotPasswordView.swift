//
//  ForgotPasswordView.swift
//  Plot
//
//  Created by Jeron Alford on 10/15/25.
//

import SwiftUI
struct ForgotPasswordView: View {
    @State private var email = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Text("Forgot password?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    TextField("E-mail", text: $email)
                }
                .modifier(AuthInputFieldStyle())
            }
            .padding(.horizontal, 20)
            
            Button("Send Reset Link") {
                // Perform password reset action here
                print("Sending reset link to \(email)")
            }
            .modifier(PrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Back to Sign In link
            HStack(spacing: 5) {
                Text("Back to")
                    .foregroundColor(.gray)
                NavigationLink {
                    LoginView() // Or pop to root if this is deep in a stack
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
            }
            .font(.callout)
            .padding(.bottom, 30)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // You might want a back button from the image.
        // For simple navigation, the default back button will appear
        // if this view is pushed onto a NavigationView stack.
    }
}

// MARK: - 3. SignUpView


// MARK: - AuthFlowView (Container for Navigation)

struct AuthFlowView: View {
    var body: some View {
        NavigationView {
            // do logic for which screen to show
            LoginView()
        }
    }
}

