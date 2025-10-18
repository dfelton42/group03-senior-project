//
//  ContentView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // HOME
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            // SEARCH
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }

            // NOTIFICATIONS
            NavigationStack {
                NotificationsView()
            }
            .tabItem {
                Image(systemName: "bell.fill")
                Text("Notifications")
            }

            // CHATBOT
            NavigationStack {
                ChatBotView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Chat")
            }
        }
        .tint(Color("AccentColor"))
        .toolbarBackground(Color("AppBackground"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .background(Color("AppBackground").ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
