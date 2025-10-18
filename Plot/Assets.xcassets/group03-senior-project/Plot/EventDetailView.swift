//
//  EventDetailView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(event.title)
                    .font(.largeTitle)
                    .bold()
                Text(event.date, style: .date)
                    .font(.headline)
                
                Divider()
                
                Text(event.description)
                    .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
