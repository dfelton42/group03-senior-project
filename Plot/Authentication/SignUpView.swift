//
//  SignUpView.swift
//  Plot
//
//  Created by Jeron Alford on 10/15/25.
//
import SwiftUI
struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField("Name", text: $name)
                }
                .modifier(AuthInputFieldStyle())
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    TextField("E-mail", text: $email)
                }
                .modifier(AuthInputFieldStyle())
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password)
                }
                .modifier(AuthInputFieldStyle())
                
                HStack {
                    Image(systemName: "lock.fill") // Reusing lock icon for consistency
                        .foregroundColor(.gray)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .modifier(AuthInputFieldStyle())
                
                // Terms & Conditions (if applicable, placeholder text)
                Text("By creating an account you agree to our Terms & Conditions.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
            }
            .padding(.horizontal, 20)
            
            Button("Create Account") {
                // Perform sign up action here
                print("Signing up with \(name), \(email), \(password)")
            }
            .modifier(PrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Already have an account link
            HStack(spacing: 5) {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                NavigationLink {
                    LoginView() // Or pop to root
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

