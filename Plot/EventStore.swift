//
//  EventStore.swift
//  Plot
//
//  Created by Julian Mazzier on 11/17/25.
//

import Foundation
import SwiftUI

@MainActor
final class EventStore: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false

    init() {
        // Start listening automatically when EventStore is created
        refreshOnNotification()
    }

    func fetch() async {
        isLoading = true
        do {
            let newEvents = try await SupabaseManager.shared.fetchEvents()
            self.events = newEvents
        } catch {
            print("❌ Failed to fetch events:", error)
        }
        isLoading = false
    }

    func refreshOnNotification() {
        NotificationCenter.default.addObserver(
            forName: .eventsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.fetch()
            }
        }
    }
}
