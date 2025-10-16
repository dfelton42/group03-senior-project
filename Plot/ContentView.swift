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
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color("AccentColor"))
                        Text("Loading events…")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else {
                    EventListView(events: events)
                        .background(Color("AppBackground"))
                }
            }
            .navigationTitle("Campus Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .task {
            do {
                events = try await SupabaseManager.shared.fetchEvents()
            } catch {
                print("Error loading events:", error)
            }
            isLoading = false
        }
    }
}
