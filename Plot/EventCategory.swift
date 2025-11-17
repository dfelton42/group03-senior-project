//
//  EventCategory.swift
//  Plot
//
//  Created by Julian Mazzier on 11/17/25.
//

//
//  EventCategory.swift
//  Plot
//

import Foundation

enum EventCategory: CaseIterable, Equatable {
    case all
    case parties
    case sports
    case greek
    case concerts
    case other

    var displayName: String {
        switch self {
        case .all: return "All"
        case .parties: return "Parties"
        case .sports: return "Sports"
        case .greek: return "Greek Life"
        case .concerts: return "Concerts"
        case .other: return "Other"
        }
    }

    var icon: String? {
        switch self {
        case .all: return "sparkles"
        case .parties: return "wineglass.fill"
        case .sports: return "sportscourt.fill"
        case .greek: return "building.columns.fill"
        case .concerts: return "music.note.list"
        case .other: return "square.grid.2x2.fill"
        }
    }

    static func forEvent(_ e: Event) -> EventCategory {
        let text = (e.title + " " + e.description).lowercased()

        if text.contains("party") || text.contains("afterparty") || text.contains("bash")
            || text.contains("mixer") || text.contains("kickoff") || text.contains("bonfire") {
            return .parties
        }

        if text.contains("hockey") || text.contains("basketball") || text.contains("soccer")
            || text.contains("tennis") || text.contains("softball") || text.contains("lacrosse")
            || text.contains("swim") {
            return .sports
        }

        if text.contains("alpha") || text.contains("beta") || text.contains("gamma")
            || text.contains("delta") || text.contains("sigma") || text.contains("kappa")
            || text.contains("zeta") {
            return .greek
        }

        if text.contains("concert") || text.contains("dj")
            || text.contains("music") || text.contains("band") {
            return .concerts
        }

        return .other
    }
}
