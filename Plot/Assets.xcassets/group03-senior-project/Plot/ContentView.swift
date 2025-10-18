//
//  ContentView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI // sample data, change once supabase is set up

struct ContentView: View {
    var body: some View {
        NavigationStack {
            EventListView(events: Event.sampleEvents)
        }
    }
}

#Preview {
    ContentView()
}
