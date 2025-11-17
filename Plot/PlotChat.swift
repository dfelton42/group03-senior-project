//
//  PlotChat.swift
//  Plot
//
//  Created by Donovan Felton on 10/17/25.
//

import SwiftUI

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatBotView: View {
    @State private var input = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hey! I’m PlotBot 👋\nAsk me anything about campus events!", isUser: false)
    ]
    @State private var allEvents: [Event] = []
    @State private var isTyping = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AppBackground"), Color.black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 18) {
                            ForEach(messages) { msg in
                                chatBubble(for: msg)
                            }

                            if isTyping {
                                typingIndicator
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
                    }
                }

                messageInputBar
                    .padding(.bottom, 6)
                    .background(.ultraThinMaterial)
                    .shadow(radius: 8)
            }
        }
        .navigationTitle("PlotBot")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do { allEvents = try await SupabaseManager.shared.fetchEvents() }
            catch { print("Failed to load events:", error) }
        }
    }

    // MARK: - Chat Bubble UI
    @ViewBuilder
    func chatBubble(for msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !msg.isUser { botAvatar }

            Text(msg.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(msg.isUser ? Color.blue.opacity(0.85) : Color.white.opacity(0.10))
                .foregroundColor(.white.opacity(msg.isUser ? 1 : 0.9))
                .cornerRadius(16)
                .frame(maxWidth: 260, alignment: msg.isUser ? .trailing : .leading)
                .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 2)

            if msg.isUser { userAvatar }
        }
        .frame(maxWidth: .infinity, alignment: msg.isUser ? .trailing : .leading)
        .id(msg.id)
    }

    // MARK: - Avatars
    var botAvatar: some View {
        Image(systemName: "bubble.left.and.bubble.right.fill")
            .font(.system(size: 28))
            .foregroundColor(.white.opacity(0.85))
            .padding(6)
            .background(Color.blue.opacity(0.4))
            .clipShape(Circle())
    }

    var userAvatar: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 26))
            .foregroundColor(.white.opacity(0.85))
            .padding(6)
            .background(Color.white.opacity(0.15))
            .clipShape(Circle())
    }

    // MARK: - Typing Indicator
    var typingIndicator: some View {
        HStack(spacing: 8) {
            botAvatar
            HStack(spacing: 4) {
                ForEach(0..<3) { _ in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.10))
            .cornerRadius(14)

            Spacer()
        }
    }

    // MARK: - Input Bar
    var messageInputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask PlotBot…", text: $input)
                .padding(12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(20)
                .foregroundColor(.white)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(Circle())
            }
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
    }

    // MARK: - Send Message
    func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(text: trimmed, isUser: true))
        input = ""
        isTyping = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let botReply = localReply(for: trimmed, events: allEvents)
            messages.append(ChatMessage(text: botReply, isUser: false))
            isTyping = false
        }
    }

    // MARK: - Event Logic
    func localReply(for query: String, events: [Event]) -> String {

        guard !events.isEmpty else {
            return "No events available right now."
        }

        let lower = query.lowercased()
        let now = Date()

        func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
            Calendar.current.isDate(d1, inSameDayAs: d2)
        }

        // TODAY
        if lower.contains("today") {
            let todays = events.filter { isSameDay($0.date, now) }
            if todays.isEmpty { return "No events today." }
            return todays
                .map { "• \($0.title)\n\($0.description)" }
                .joined(separator: "\n\n")
        }

        // TOMORROW
        if lower.contains("tomorrow") {
            guard let tmr = Calendar.current.date(byAdding: .day, value: 1, to: now) else {
                return "Try again."
            }
            let list = events.filter { isSameDay($0.date, tmr) }
            if list.isEmpty { return "No events tomorrow." }
            return list
                .map { "• \($0.title)\n\($0.description)" }
                .joined(separator: "\n\n")
        }

        // Explicit next-event style queries
        if lower == "next event" ||
            lower.contains("what's next") ||
            lower.contains("next event") ||
            lower.contains("upcoming events") {

            let upcoming = events.filter { $0.date > now }
            if let nearest = upcoming.min(by: { $0.date < $1.date }) {
                return "The next event coming up is \(nearest.title).\n\(nearest.description)"
            }
            return "No upcoming events."
        }

        // Keyword search (only if query long enough)
        if lower.count >= 3 {
            let matches = events.filter {
                $0.title.lowercased().contains(lower) ||
                $0.description.lowercased().contains(lower)
            }

            if !matches.isEmpty {
                return matches
                    .map { "• \($0.title)\n\($0.description)" }
                    .joined(separator: "\n\n")
            }
        }

        return "I couldn't find anything for \"\(query)\". Try searching for party, sports, game, or club."
    }
}

#Preview {
    NavigationStack { ChatBotView() }
}
