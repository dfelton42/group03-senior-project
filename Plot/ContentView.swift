//
//  ContentView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var events: [Event] = []

    var body: some View {
        NavigationStack {
            if authViewModel.isLoading {
                ProgressView("Loading...")
            } else if !authViewModel.isAuthenticated {
                LoginView()
            } else {
                EventListView(events: events)
                    .toolbar {
                        Button("Sign Out") {
                            Task { await authViewModel.signOut() }
                        }
                    }
                    .task {
                        // Load events when signed in
                        do {
                            events = try await SupabaseManager.shared.fetchEvents()
                        } catch {
                            print("❌ Failed to fetch events:", error.localizedDescription)
                        }
                    }
            }
        }
    }
}
