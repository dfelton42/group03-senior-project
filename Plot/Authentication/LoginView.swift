//
//  LoginView.swift
//  Plot
//
//  Created by Jeron Alford on 10/15/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
                    Image(systemName: "envelope.fill").foregroundColor(.gray)
                    TextField("E-mail", text: $email)
                        .modifier(AuthInputFieldStyle())
                }

                HStack {
                    Image(systemName: "lock.fill").foregroundColor(.gray)
                    SecureField("Password", text: $password)
                        .modifier(AuthInputFieldStyle())
                }
            }
            .padding(.horizontal, 20)

            Button("Log In") {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            }
            .modifier(PrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()
        }
        .navigationBarHidden(true)
    }
}
