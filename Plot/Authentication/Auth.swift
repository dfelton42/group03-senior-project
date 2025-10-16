//
//  Authentication.swift
//  Plot
//
//  Created by Jeron Alford on 10/6/25.
//
import SwiftUI

struct AuthView : View {
    // TODO: set isLoading flag to true when checkAuthenticationStatus() is implemented
    @State private var isLoading = false
    @State private var showLoginView = true
    
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Checking Authentication...")
            } else {
                // Check if user is not logged in, or if they toggle to login view
                if (!isAuthenticated || showLoginView) {
                    AuthLoginView()
                } else {
                    AuthSignupView()
                }
            }
        }
        .onAppear {
            // 1. Perform initial authentication check when the view appears
            // TODO: Implement checkAuthenticationStatus()
        }
    }
}

