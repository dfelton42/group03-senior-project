//
//  LoginView.swift
//  Plot
//
//  Created by Jeron Alford on 10/15/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isBusy = false

    var body: some View {
        AuthScaffold(title: "Sign In") {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill").foregroundColor(.white.opacity(0.6))
                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                }
                .authField()

                HStack(spacing: 10) {
                    Image(systemName: "lock.fill").foregroundColor(.white.opacity(0.6))
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .submitLabel(.go)
                }
                .authField()

                HStack {
                    Spacer()
                    NavigationLink { ForgotPasswordView() } label: {
                        Text("Forgot password?")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .padding(.top, -4)

                Button {
                    Task {
                        guard !isBusy else { return }
                        isBusy = true
                        defer { isBusy = false }
                        await authVM.signIn(email: email, password: password)
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isBusy { ProgressView().tint(.white) }
                        Text(isBusy ? "Signing in…" : "Log In")
                    }
                }
                .primaryCTA()
                .padding(.top, 4)

                Spacer()

                HStack(spacing: 6) {
                    Text("Don't have an account?").muted()
                    NavigationLink { SignUpView() } label: {
                        Text("Create one")
                            .fontWeight(.semibold)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .font(.callout)
                .padding(.bottom, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
