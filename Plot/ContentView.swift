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
            } else {
                if isLoading {
                    ProgressView("Loading events…")
                } else {
                    EventListView(events: events)
                }
            }
        }
        // MARK: - Exchange URL callback from Supabase
        .onOpenURL { url in
            Task {
                do {
                  
                    // Extract the "code" or "access_token" parameter from the deep link
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let queryItems = components.queryItems,
                       let code = queryItems.first(where: { $0.name == "code" || $0.name == "access_token" })?.value {
                        
                        try await SupabaseManager.shared.client.auth.exchangeCodeForSession(authCode: code)
                    } else {
                        print("❌ Missing auth code in deep‑link URL.")
                    }
                    // ✅ After the exchange, update state and load events
                    if await SupabaseManager.shared.isUserAuthenticated() {
                        isAuthenticated = true
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
        // MARK: - Regular Auth Check (runs when app launches)
        .task {
            do {
                isAuthenticated = await SupabaseManager.shared.isUserAuthenticated()
                
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
