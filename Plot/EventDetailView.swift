//
//  EventDetailView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    
    @State private var region: MKCoordinateRegion
    
    init(event: Event) {
        self.event = event
        _region = State(initialValue: MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
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
                
                Divider()
                
                Map(coordinateRegion: $region, annotationItems: [event]) { event in
                    MapMarker(coordinate: event.coordinate, tint: .blue)
                }
                .frame(height: 250)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
