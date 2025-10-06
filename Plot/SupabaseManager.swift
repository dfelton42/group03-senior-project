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
    
    func fetchEvents() async throws -> [Event] {
        let response: [Event] = try await client
            .database
            .from("events")
            .select()
            .execute()
            .value
        return response
    }
}
