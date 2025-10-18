//
//  ChatService.swift
//  Plot
//
//  Created by Donovan Felton on 10/18/25.
//

func localReply(for query: String, events: [Event]) -> String {
    let matches = events.filter {
        $0.title.localizedCaseInsensitiveContains(query) ||
        $0.description.localizedCaseInsensitiveContains(query)
    }
    if matches.isEmpty {
        return "No events found matching '\(query)'."
    }
    return matches.map { "\($0.title) — \($0.description)" }.joined(separator: "\n\n")
}
