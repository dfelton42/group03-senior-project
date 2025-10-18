//
//  PlotChat.swift
//  Plot
//
//  Created by Donovan Felton on 10/17/25.
//

import SwiftUI

struct ChatBotView: View {
    @State private var input = ""
    @State private var messages: [String] = ["Welcome to Plot Chat! Ask me about any event."]
    @State private var allEvents: [Event] = []
    @State private var isLoading = true

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }

            HStack {
                TextField("Type a question...", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.white)
                    .tint(.white)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                Button("Send") {
                    let userText = input.trimmingCharacters(in: .whitespaces)
                    guard !userText.isEmpty else { return }

                    messages.append("You: \(userText)")
                    input = ""

                    let reply = localReply(for: userText, events: allEvents)
                    messages.append("Bot: \(reply)")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .navigationTitle("Event Chatbot")
        .task {
            do {
                allEvents = try await SupabaseManager.shared.fetchEvents()
                isLoading = false
            } catch {
                print("Error loading events:", error)
                isLoading = false
            }
        }
    }

    // MARK: - Local search logic
    func localReply(for query: String, events: [Event]) -> String {
        guard !events.isEmpty else { return "No events available right now." }

        let lower = query.lowercased()
        let now = Date()

        // --- based on time, can add complexity later such as distance---
        if lower.contains("next") || lower.contains("soon") || lower.contains("upcoming") {
            if let nearest = events.filter({ $0.date > now }).sorted(by: { $0.date < $1.date }).first {
                return "The next event is \(nearest.title) — \(nearest.description)\n📅 \(nearest.date.formatted(date: .abbreviated, time: .shortened))"
            } else {
                return "No upcoming events found."
            }
        }

        if lower.contains("today") {
            let todays = events.filter { Calendar.current.isDate($0.date, inSameDayAs: now) }
            if todays.isEmpty {
                return "No events today."
            }
            return todays.map { "• \($0.title)\n   \($0.description)" }.joined(separator: "\n\n")
        }

        if lower.contains("tomorrow") {
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) {
                let tmrEvents = events.filter { Calendar.current.isDate($0.date, inSameDayAs: tomorrow) }
                if tmrEvents.isEmpty { return "No events tomorrow." }
                return tmrEvents.map { "• \($0.title)\n   \($0.description)" }.joined(separator: "\n\n")
            }
        }

        // --- KEYWORD MATCH (fallback) ---
        let matches = events.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.description.localizedCaseInsensitiveContains(query)
        }

        if matches.isEmpty {
            return "I couldn't find any events matching '\(query)'. Try another word."
        }

        return matches
            .map { "• \($0.title)\n   \($0.description)\n   📅 \($0.date.formatted(date: .abbreviated, time: .shortened))" }
            .joined(separator: "\n\n")
    }

}

#Preview {
    ChatBotView()
}

