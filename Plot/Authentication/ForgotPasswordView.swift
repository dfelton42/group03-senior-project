//
//  ForgotPasswordView.swift
//  Plot
//
//  Created by Jeron Alford on 10/15/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isBusy = false

    var body: some View {
        AuthScaffold(title: "Forgot password?") {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill").foregroundColor(.white.opacity(0.6))
                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .submitLabel(.done)
                }
                .authField()

                Button {
                    Task {
                        guard !isBusy else { return }
                        isBusy = true
                        defer { isBusy = false }
                        do {
                            try await SupabaseManager.shared.sendPasswordReset(email: email)
                            print("📩 Password reset link sent to \(email)")
                        } catch {
                            print("❌ Error sending reset link: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isBusy { ProgressView().tint(.white) }
                        Text(isBusy ? "Sending…" : "Send Reset Link")
                    }
                }
                .primaryCTA()
                .padding(.top, 4)

                Spacer()

                HStack(spacing: 6) {
                    Text("Back to").muted()
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
