//
//  Event.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
}

// Example mock data
extension Event {
    static let sampleEvents: [Event] = [
        Event(id: UUID(), title: "Rugby Party", description: "Party at rugby house", date: Date()),
        Event(id: UUID(), title: "Fallapalooza", description: "Concert on sunken garden", date: Date().addingTimeInterval(86400))
    ]
}
