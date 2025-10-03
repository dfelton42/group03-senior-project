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
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Example mock data
extension Event {
    static let sampleEvents: [Event] = [
        Event(id: UUID(),
              title: "Rugby Party",
              description: "Party at rugby house",
              date: Date(),
              latitude: 37.7749,
              longitude: -122.4194),
        
        Event(id: UUID(),
              title: "Fallapalooza",
              description: "Concert on sunken garden",
              date: Date().addingTimeInterval(86400),
              latitude: 34.0522,
              longitude: -118.2437)
    ]
}
