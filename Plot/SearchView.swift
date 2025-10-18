//
//  SearchView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/15/25.
//
import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var events: [Event] = []
    @State private var isLoading = true

    var filteredEvents: [Event] {
        if query.isEmpty { return events }
        return events.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading…")
                        .foregroundColor(.white)
                } else if filteredEvents.isEmpty {
                    List {
                        Section {
                            Text("No results. Try searching for parties, teams, houses, or venues.")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .listRowBackground(Color.white.opacity(0.06))
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    EventListView(events: filteredEvents)
                }
            }
            .background(Color("AppBackground"))
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search events or places")
        }
        .task {
            do {
                events = try await SupabaseManager.shared.fetchEvents()
            } catch {
                print("Error fetching events:", error)
            }
            isLoading = false
        }
    }
}

#Preview {
    ContentView()
}
