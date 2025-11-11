//
//  AuthViewModel.swift
//  Plot
//
//  Created by Julian Mazzier on 11/10/25.
//

import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true

    init() {
        Task {
            await checkSession()
        }
    }

    func checkSession() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            isAuthenticated = (session.user != nil)
        } catch {
            isAuthenticated = false
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        do {
            try await SupabaseManager.shared.signIn(email: email, password: password)
            await checkSession()
            print("✅ AuthViewModel signed in successfully")
        } catch {
            print("❌ AuthViewModel sign-in failed:", error.localizedDescription)
        }
    }

    func signOut() async {
        await SupabaseManager.shared.signOut()
        isAuthenticated = false
    }
}
