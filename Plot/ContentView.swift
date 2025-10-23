//
//  ContentView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//
import SwiftUI

struct ContentView: View {
    @State private var events: [Event] = []
    @State private var isLoading: Bool = true
    @State private var isAuthenticated: Bool = false
    var body: some View {
        NavigationStack {
            if !isAuthenticated {
                LoginView()
            }
            else{
                if isLoading {
                    ProgressView("Loading events…")
                } else {
                    EventListView(events: events)
                }
            }
        }
        .task {
            do {
                isAuthenticated = try await SupabaseManager.shared.isUserAuthenticated()
                
                if isAuthenticated {
                    events = try await SupabaseManager.shared.fetchEvents()
                    isLoading = false
                }
            } catch {
                print("Error loading events:", error)
            }
        }
    }
}

