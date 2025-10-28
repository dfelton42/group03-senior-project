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
                Task {
                    do {
                        try await SupabaseManager.shared.sendPasswordReset(email: email)
                        print("📩 Password reset link sent to \(email)")
                    } catch {
                        print("❌ Error sending reset link: \(error.localizedDescription)")
                    }
                }
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
                    LoginView()
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
        
    }
}

// MARK: - 3. SignUpView


// MARK: - AuthFlowView (Container for Navigation)

struct AuthFlowView: View {
    var body: some View {
        NavigationView {
          
            LoginView()
        }
    }
}

