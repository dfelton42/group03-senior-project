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
    @State private var attendingEvent: Bool = false
    @State private var isLoadingRsvp : Bool = true
    
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
                if isLoadingRsvp {
                                    // Show a loading indicator while fetching initial status
                                    ProgressView("Checking RSVP...")
                                        .frame(maxWidth: .infinity)
                                }
                else if attendingEvent {
                    Button("Cancel RSVP") {
                        Task {
                            do {
                                attendingEvent = false
                                try await SupabaseManager.shared.removeRsvp(eventId: event.id)
                                print("removed rsvp")
                            } catch {
                                print("❌ Error canceling RSVP: \(error.localizedDescription)")
                            }
                        }
                    }
                    .modifier(SecondaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                } else {
                    Button("I'm going") {
                        Task {
                            do {
                                
                                attendingEvent = true
                                try await SupabaseManager.shared.addRsvp(eventId: event.id)
                                print("adding rsvp")
                            } catch {
                                print("❌ Error creating RSVP: \(error.localizedDescription)")
                            }
                        }
                    }
                    .modifier(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                let status = try await SupabaseManager.shared.fetchRsvpStatus(eventId:event.id)
                attendingEvent = status
            } catch {
                print("❌ Failed to fetch initial RSVP status: \(error.localizedDescription)")
                attendingEvent = false // Assume not attending on error
            }
            isLoadingRsvp = false // Stop loading after the fetch (success or fail)
        }
    }
}
