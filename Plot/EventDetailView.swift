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

                Spacer(minLength: 8)
            }
            .padding(16)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
