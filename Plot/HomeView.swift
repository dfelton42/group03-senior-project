//
//  HomeView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/15/25.
//

import SwiftUI

struct HomeView: View {
    @State private var events: [Event] = []
    @State private var isLoading = true

    var body: some View {
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

        .toolbar {
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .foregroundColor(.white)
            }
        }

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

#Preview {
    HomeView()
}
