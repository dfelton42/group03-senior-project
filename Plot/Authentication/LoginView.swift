//
//  LoginView.swift
//  Plot
//
//  Created by Jeron Alford on 10/15/25.
//
import SwiftUI
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 25) { 
            Spacer()
            
            Text("Sign In")
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
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password)
                }
                .modifier(AuthInputFieldStyle())
                
            
                HStack {
                    Spacer()
                    NavigationLink {
                        ForgotPasswordView()
                    } label: {
                        Text("Forgot password?")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }
                }
                .padding(.top, -10)
            }
            .padding(.horizontal, 20)
            
            Button("Log In") {
      
                print("Logging in with \(email) and \(password)")
            }
            .modifier(PrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
        
            HStack(spacing: 5) {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Create one")
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
            }
            .font(.callout)
            .padding(.bottom, 30)
        }
        .navigationBarHidden(true)
    }
}
