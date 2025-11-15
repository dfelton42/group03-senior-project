//
//  ContentView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var events: [Event] = []
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            if authVM.isLoading {
                ProgressView("Loading…")
                    .tint(Color("AccentColor"))
            } else if !authVM.isAuthenticated {
                NavigationStack {
                    LoginView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
            } else {
                TabView {
                    // HOME
                    NavigationStack {
                        HomeView(events: events, isLoading: isLoading)
                            .navigationTitle("Campus Events")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .toolbar {
                                Button("Sign Out") { Task { await authVM.signOut() } }
                            }
                    }
                    .tabItem { Image(systemName: "house.fill"); Text("Home") }

                    // SEARCH
                    NavigationStack {
                        SearchView(allEvents: events)
                            .navigationTitle("Search")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                    }
                    .tabItem { Image(systemName: "magnifyingglass"); Text("Search") }
                    
                    // CREATE EVENT
                    NavigationStack {
                        CreateEventView {
                            Task {
                                do {
                                    let newEvents = try await SupabaseManager.shared.fetchEvents()
                                    await MainActor.run {
                                        events = newEvents   // ensures UI actually refreshes
                                    }
                                } catch {
                                    print("Reload error:", error)
                                }
                            }
                        }
                        .navigationTitle("Create Event")                        
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                    }
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }

                    // NOTIFICATIONS
                    NavigationStack {
                        NotificationsView()
                            .navigationTitle("Notifications")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                    }
                    .tabItem { Image(systemName: "bell.fill"); Text("Notifications") }
                }
                .tint(Color("AccentColor"))
                .toolbarBackground(Color("AppBackground"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .background(Color("AppBackground").ignoresSafeArea())
            }
        }
        .preferredColorScheme(.dark)

        // deep links
        .onOpenURL { url in
            Task {
                do {
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let queryItems = components.queryItems,
                       let code = queryItems.first(where: { $0.name == "code" || $0.name == "access_token" })?.value {
                        _ = try await SupabaseManager.shared.client.auth
                            .exchangeCodeForSession(authCode: code)
                    } else {
                        print("❌ Missing auth code in deep-link URL.")
                    }

                    await authVM.checkSession()
                    if authVM.isAuthenticated {
                        isLoading = true
                        events = try await SupabaseManager.shared.fetchEvents()
                        isLoading = false
                    }
                    print("✅ Supabase session restored via deep link.")
                } catch {
                    print("❌ Failed to exchange auth code:", error)
                }
            }
        }

        // initial auth/events
        .task {
            await authVM.checkSession()
            if authVM.isAuthenticated {
                do { events = try await SupabaseManager.shared.fetchEvents() }
                catch { print("Error loading events:", error) }
            }
            isLoading = false
        }
    }
}
