//
//  ContentView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var eventStore: EventStore

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
                    // 🏠 HOME
                    NavigationStack {
                        HomeView()
                            .navigationTitle("Campus Events")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .toolbar {
                                Button("Sign Out") {
                                    Task { await authVM.signOut() }
                                }
                            }
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                    // 🔍 SEARCH
                    NavigationStack {
                        SearchView()
                            .navigationTitle("Search")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                    }
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }

                    // ➕ CREATE
                    NavigationStack {
                        CreateEventView {
                            Task { await eventStore.fetch() }
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

                    // 🔔 NOTIFICATIONS
                    NavigationStack {
                        NotificationsView()
                            .navigationTitle("Notifications")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                    }
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Notifications")
                    }

                    // 💬 CHAT
                    NavigationStack {
                        ChatBotView()
                            .navigationTitle("Chat")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                    }
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Chat")
                    }
                }
                .tint(Color("AccentColor"))
                .toolbarBackground(Color("AppBackground"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .background(Color("AppBackground").ignoresSafeArea())
            }
        }
        .preferredColorScheme(.dark)
        .task {
            // Initialize auth + load events
            await authVM.checkSession()

            if authVM.isAuthenticated {
                await eventStore.fetch()
                eventStore.refreshOnNotification() // Listen for .eventsDidChange
            }
        }
    }
}
