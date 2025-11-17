//
//  SupabaseManager.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    var currentUser: User?

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://zffnbseyutdajtkhmgvl.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmZm5ic2V5dXRkYWp0a2htZ3ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3ODYzODQsImV4cCI6MjA3NTM2MjM4NH0.r4z5R9gufafrMQ_HvHbb9Yna0a5zlv1244v4tD-wWUU"
        )
    }

    // MARK: - Events

    func fetchEvents() async throws -> [Event] {
        try await client.database
            .from("events")
            .select()
            .order("date", ascending: true)
            .execute()
            .value as [Event]
    }

    func createEvent(
        title: String,
        description: String,
        date: Date,
        latitude: Double?,
        longitude: Double?,
        rsvps: Int = 0
    ) async throws {
        struct NewEvent: Encodable {
            let id: UUID
            let title: String
            let description: String
            let date: Date
            let latitude: Double?
            let longitude: Double?
            let rsvps: Int
            // upvote/downvote counts exist in DB with default 0
        }

        let event = NewEvent(
            id: UUID(),
            title: title,
            description: description,
            date: date,
            latitude: latitude,
            longitude: longitude,
            rsvps: rsvps
        )

        try await client.database
            .from("events")
            .insert([event])
            .execute()
    }

    // MARK: - User Event Actions (RSVP + Voting)

    /// Fetches the row in `user_event_actions` for this user/event.
    func fetchUserEventActions(eventId: UUID) async throws -> [[String: Any]] {
        let session = try await client.auth.session

        let response = try await client.database
            .from("user_event_actions")
            .select()
            .eq("event_id", value: eventId)
            .eq("user_id", value: session.user.id)
            .execute()

        let jsonData = response.data
        if jsonData.isEmpty { return [] }

        let decodedObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let records = decodedObject as? [[String: Any]] else {
            return []
        }
        return records
    }

    /// Marks the user as attending this event.
    /// If a row already exists for this (event_id, user_id), it flips `is_attending` back to true
    /// instead of inserting a duplicate row (which would violate the composite primary key).
    func addRsvp(eventId: UUID) async throws {
        let session = try await client.auth.session
        let userId = session.user.id

        // Check if a user_event_actions row already exists
        let existingRecords = try await fetchUserEventActions(eventId: eventId)

        if existingRecords.isEmpty {
            // No row yet -> INSERT (is_attending will default to true in DB)
            try await client.database
                .from("user_event_actions")
                .insert([
                    "event_id": eventId,
                    "user_id": userId
                ])
                .execute()
        } else {
            // Row exists -> set is_attending back to true
            try await client.database
                .from("user_event_actions")
                .update([
                    "is_attending": true
                ])
                .eq("event_id", value: eventId)
                .eq("user_id", value: userId)
                .execute()
        }
    }

    /// Marks the user as *not* attending this event.
    func removeRsvp(eventId: UUID) async throws {
        let session = try await client.auth.session
        let userId = session.user.id

        try await client.database
            .from("user_event_actions")
            .update([
                "is_attending": false
            ])
            .eq("event_id", value: eventId)
            .eq("user_id", value: userId)
            .execute()
    }

    /// Updates the user's upvote/downvote status for this event.
    func updateUserVoteStatus(eventId: UUID, voteAction: VoteAction) async throws {
        let session = try await client.auth.session
        let userId = session.user.id

        try await client.database
            .from("user_event_actions")
            .update([
                "is_upvoting": (voteAction == .upvote),
                "is_downvoting": (voteAction == .downvote)
            ])
            .eq("event_id", value: eventId)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - Authentication

    func signUp(email: String, password: String) async throws {
        guard email.lowercased().hasSuffix("@lion.lmu.edu") else {
            throw NSError(
                domain: "AuthError",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "You must use a @lion.lmu.edu email address."]
            )
        }
        try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func sendPasswordReset(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    func signOut() async {
        try? await client.auth.signOut()
    }

    func isUserAuthenticated() async -> Bool {
        do {
            let session = try await client.auth.session
            currentUser = session.user
            return session.user != nil
        } catch {
            currentUser = nil
            return false
        }
    }
}
