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

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://zffnbseyutdajtkhmgvl.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmZm5ic2V5dXRkYWp0a2htZ3ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3ODYzODQsImV4cCI6MjA3NTM2MjM4NH0.r4z5R9gufafrMQ_HvHbb9Yna0a5zlv1244v4tD-wWUU"
        )
    }

    // MARK: - Database

    func fetchEvents() async throws -> [Event] {
        try await client.database
            .from("events")
            .select()
            .order("date", ascending: true)
            .execute()
            .value
    }

    // MARK: - RSVP (note the awaited session.user.id)

    func fetchRsvpStatus(eventId: UUID) async throws -> Bool {
        let session = try await client.auth.session
        let response = try await client.database
            .from("rsvps")
            .select()
            .eq("event_id", value: eventId)
            .eq("user_id", value: session.user.id)
            .execute()

        if response.data.isEmpty { return false }

        let decoded = try JSONSerialization.jsonObject(with: response.data)
        guard let rows = decoded as? [[String: Any]] else { return false }
        return !rows.isEmpty
    }

    func addRsvp(eventId: UUID) async throws {
        let session = try await client.auth.session
        try await client.database
            .from("rsvps")
            .insert([
                "event_id": eventId,
                "user_id": session.user.id
            ])
            .execute()
    }

    func removeRsvp(eventId: UUID) async throws {
        let session = try await client.auth.session
        try await client.database
            .from("rsvps")
            .delete()
            .eq("event_id", value: eventId)
            .eq("user_id", value: session.user.id)
            .execute()
    }

    // MARK: - Auth

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
            return session.user != nil
        } catch {
            return false
        }
    }
}
