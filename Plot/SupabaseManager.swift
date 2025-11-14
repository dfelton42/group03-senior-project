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
    
    //Î Database
    func fetchEvents() async throws -> [Event] {
        try await client.database
            .from("events")
            .select()
            .order("date", ascending: true)
            .execute()
            .value
    }
    func fetchUserEventActions(eventId: UUID) async throws -> [[String: Any]] {
        // TODO: create an AuthService Object so that there are not repeated calls to get user Id
        // TODO: create Client-Side caching for event rsvp status to limit refetches on new event load
        let response = try await client.database
            .from("user_event_actions")
            .select()
            .eq("event_id", value: eventId)
            .eq("user_id", value: client.auth.session.user.id)
            .execute()
        let jsonData = response.data
        if jsonData.isEmpty { return []}
        
        let decodedObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
        guard let rsvpRecords = decodedObject as? [[String: Any]] else {
            return []
        }
        
        return rsvpRecords
    }

    func addRsvp(eventId: UUID) async throws {
        try await client.database
            .from("user_event_actions")
            .insert([
                "event_id": eventId,
                "user_id": client.auth.session.user.id
            ])
            .execute()
    }
    
    
    func removeRsvp(eventId:UUID) async throws {
        try await client.database
            .from("user_event_actions")
            .update([
                "is_attending": false
            ])
            .eq("event_id", value: eventId)
            .eq("user_id", value: client.auth.session.user.id)
            .execute()
    }
    func updateUserVoteStatus(eventId: UUID, voteAction: VoteAction) async throws {
         // Logic to add, update, or remove the vote based on the enum value
        try await client.database
            .from("user_event_actions")
            .update([
                "is_upvoting": voteAction == VoteAction.upvote,
                "is_downvoting": voteAction == VoteAction.downvote
            ])
            .eq("event_id", value: eventId)
            .eq("user_id", value: client.auth.session.user.id)
            .execute()
    }
    
    
    // Authentication
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
            self.currentUser = try await client.auth.session.user
            return true
        } catch {
            return false
        }
    }
}
