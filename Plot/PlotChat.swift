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
        ChatMessage(text: "Hey! I’m PlotBot 👋\nAsk me anything about your campus events!", isUser: false)
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
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
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
            do {
                allEvents = try await SupabaseManager.shared.fetchEvents()
            } catch {
                print("❌ Failed to load:", error)
            }
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
                .background(
                    msg.isUser
                    ? Color.blue.opacity(0.85)
                    : Color.white.opacity(0.10)
                )
                .foregroundColor(.white.opacity(msg.isUser ? 1 : 0.9))
                .cornerRadius(16)
                .frame(maxWidth: 260, alignment: msg.isUser ? .trailing : .leading)
                .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 2)
                .transition(.move(edge: msg.isUser ? .trailing : .leading).combined(with: .opacity))

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
                Circle().frame(width: 8, height: 8).foregroundColor(.white.opacity(0.6))
                Circle().frame(width: 8, height: 8).foregroundColor(.white.opacity(0.6))
                Circle().frame(width: 8, height: 8).foregroundColor(.white.opacity(0.6))
            }
            .padding(10)
            .background(Color.white.opacity(0.10))
            .cornerRadius(14)

            Spacer()
        }
        .transition(.opacity)
    }

    // MARK: - Input Bar
    var messageInputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask PlotBot…", text: $input)
                .padding(12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(20)
                .foregroundColor(.white)
                .tint(Color.white)

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

    // MARK: - Sending Messages
    func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = ChatMessage(text: trimmed, isUser: true)
        messages.append(userMessage)
        input = ""

        isTyping = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let fixed = correctedQuery(trimmed)
            let botReply = localReply(for: fixed, events: allEvents)

            messages.append(ChatMessage(text: botReply, isUser: false))

            withAnimation(.easeIn(duration: 0.2)) {
                isTyping = false
            }
        }
    }

    // MARK: - Event Logic
    func localReply(for query: String, events: [Event]) -> String {
        guard !events.isEmpty else { return "Hmm… I’m not seeing any events right now! Try again soon 😌" }

        let lower = query.lowercased()
        let now = Date()

        if lower.contains("today") {
            let todays = events.filter { Calendar.current.isDate($0.date, inSameDayAs: now) }
            if todays.isEmpty { return "Nothing today — maybe a chill day? 😴" }
            return todays.map { "• \($0.title)\n\($0.description)" }.joined(separator: "\n\n")
        }

        if lower.contains("tomorrow") {
            if let tmr = Calendar.current.date(byAdding: .day, value: 1, to: now) {
                let list = events.filter { Calendar.current.isDate($0.date, inSameDayAs: tmr) }
                if list.isEmpty { return "No events tomorrow… want me to recommend something instead? 🔮" }
                return list.map { "• \($0.title)\n\($0.description)" }.joined(separator: "\n\n")
            }
        }

        if lower.contains("next") || lower.contains("soon") || lower.contains("upcoming") {
            if let nearest = events.min(by: {
                abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now))
            }) {
                return "🔥 The next big thing is **\(nearest.title)**!\nHere’s the vibe:\n\(nearest.description)"
            }
        }

        let matches = events.filter {
            $0.title.lowercased().contains(lower) || $0.description.lowercased().contains(lower)
        }

        if !matches.isEmpty {
            return matches.map {
                "• \($0.title)\n\($0.description)"
            }.joined(separator: "\n\n")
        }

        return "Hmm… nothing matches “\(query)”. Try asking about *party*, *hockey*, or *concert* 🎉"
    }

    // MARK: - Levenshtein
    func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a.lowercased())
        let b = Array(b.lowercased())
        var dist = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                dist[i][j] = min(
                    dist[i-1][j] + 1,
                    dist[i][j-1] + 1,
                    dist[i-1][j-1] + (a[i-1] == b[j-1] ? 0 : 1)
                )
            }
        }
        return dist[a.count][b.count]
    }

    func correctedQuery(_ text: String) -> String {
        let common = ["today","tomorrow","next","party","concert","event","hockey","house","team"]
        let words = text.split(separator: " ")

        return words.map { word in
            common.min(by: { levenshtein(String(word), $0) < levenshtein(String(word), $1) }) ?? String(word)
        }.joined(separator: " ")
    }
}

#Preview {
    NavigationStack {
        ChatBotView()
    }
}
