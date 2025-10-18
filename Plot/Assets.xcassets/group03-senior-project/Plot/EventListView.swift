//
//  EventListView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI

struct EventListView: View {
    let events: [Event]
    
    var body: some View {
        List(events) { event in
            NavigationLink(destination: EventDetailView(event: event)) {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Campus Events")
    }
}
