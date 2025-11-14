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
            }
            else if !authVM.isAuthenticated {
                // SIGN-IN SCREEN
                NavigationStack {
                    LoginView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
            }
            else {
                TabView {

                    NavigationStack {
                        HomeView(events: events, isLoading: isLoading)
                            .navigationTitle("Campus Events")
                            .navigationBarTitleDisplayMode(.inline)
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

                    NavigationStack {
                        SearchView(allEvents: events)
                            .navigationTitle("Search")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }

                    
                    NavigationStack {
                        NotificationsView()
                            .navigationTitle("Notifications")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Notifications")
                    }

                    //--------------------------------------------------
                    // CHAT (just added dis)
                    //--------------------------------------------------
                    NavigationStack {
                        ChatBotView()
                            .navigationTitle("Chat")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Chat")
                    }
                }
                .tint(Color("AccentColor"))
            }
        }
        .preferredColorScheme(.dark)

        //----------------------------------------------------------
        // INITIAL EVENT LOAD
        //----------------------------------------------------------
        .task {
            do {
                events = try await SupabaseManager.shared.fetchEvents()
            } catch {
                print("❌ Error loading events:", error)
            }

            isLoading = false
        }
    }
}


// MARK: - PREVIEW
#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
