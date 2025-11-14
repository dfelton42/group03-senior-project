//
//  Event.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import Foundation
import CoreLocation

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    let latitude: Double?
    let longitude: Double?
    let rsvps: Int
    let upvote_count: Int
    let downvote_count: Int

    // Derived coordinate for MapKit etc.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? 0,
            longitude: longitude ?? 0
        )
    }
}
