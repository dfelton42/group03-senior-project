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
            supabaseURL: URL(string: "https://our_url_here.supabase.co")!,
            supabaseKey: "Our_Key"
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
