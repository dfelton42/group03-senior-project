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
    @State private var attending = false
    @State private var checking = true
    
    @StateObject private var locationManager = LocationManager()

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
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text(event.date, style: .date)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))

                Divider().background(Color.white.opacity(0.1))

                Text(event.description)
                    .foregroundColor(.white.opacity(0.9))

                Divider().background(Color.white.opacity(0.1))

                Map(position: .constant(.region(region))) {
                    Annotation(event.title, coordinate: event.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(Color("AccentColor"))
                            .shadow(radius: 3)
                    }
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.07))
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)

                if checking {
                    ProgressView("Checking RSVP…")
                        .tint(Color("AccentColor"))
                } else if attending {
                    Button("Cancel RSVP") {
                        Task {
                            do {
                                try await SupabaseManager.shared.removeRsvp(eventId: event.id)
                                attending = false
                            } catch {
                                print("❌ cancel RSVP:", error.localizedDescription)
                            }
                        }
                    }
                    .modifier(PrimaryButtonStyle(backgroundColor: .white, foregroundColor: .black))
                } else {
                    Button("I’m going") {
                        Task {
                            do {
                                try await SupabaseManager.shared.addRsvp(eventId: event.id)
                                attending = true
                            } catch {
                                print("❌ add RSVP:", error.localizedDescription)
                            }
                        }
                    }
                    .primaryCTA()
                }

                // MARK: - USER LOCATION SECTION
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Location:")
                        .font(.headline)
                        .foregroundColor(.white)

                    if locationManager.isAuthorized {
                        if let loc = locationManager.userLocation {
                            Text("Lat: \(loc.latitude), Lon: \(loc.longitude)")
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            Text("Locating…")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Text("Location access not granted.")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.top, 12)

            }
            .padding(16)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            // Request location immediately
            locationManager.requestLocation()

            // Fetch RSVP status
            do {
                let status = try await SupabaseManager.shared.fetchRsvpStatus(eventId: event.id)
                attending = status
            } catch {
                attending = false
            }
            checking = false
        }
    }
}

