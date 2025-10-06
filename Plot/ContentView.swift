//
//  ContentView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//
import SwiftUI

struct ContentView: View {
    @State private var events: [Event] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading events…")
            } else {
                EventListView(events: events)
            }
        }
        .task {
            do {
                events = try await SupabaseManager.shared.fetchEvents()
                isLoading = false
            } catch {
                print("Error loading events:", error)
            }
        }
    }
}
