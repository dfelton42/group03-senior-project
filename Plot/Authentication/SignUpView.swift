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
    @State private var isBusy = false

    var body: some View {
        AuthScaffold(title: "Sign Up") {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "person.fill").foregroundColor(.white.opacity(0.6))
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .submitLabel(.next)
                }
                .authField()

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
                        .textContentType(.newPassword)
                        .submitLabel(.next)
                }
                .authField()

                HStack(spacing: 10) {
                    Image(systemName: "lock.fill").foregroundColor(.white.opacity(0.6))
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .submitLabel(.go)
                }
                .authField()

                Text("By creating an account you agree to our Terms & Conditions.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)

                Button {
                    guard password == confirmPassword else {
                        print("❌ Passwords do not match")
                        return
                    }
                    Task {
                        guard !isBusy else { return }
                        isBusy = true
                        defer { isBusy = false }
                        do {
                            try await SupabaseManager.shared.signUp(email: email, password: password)
                            print("✅ Account created! Check your LMU email for confirmation.")
                        } catch {
                            print("❌ Error creating account: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isBusy { ProgressView().tint(.white) }
                        Text(isBusy ? "Creating…" : "Create Account")
                    }
                }
                .primaryCTA()
                .padding(.top, 4)

                Spacer()

                HStack(spacing: 6) {
                    Text("Already have an account?").muted()
                    NavigationLink { LoginView() } label: {
                        Text("Sign In")
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
