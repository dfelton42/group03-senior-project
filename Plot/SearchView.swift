//
//  SearchView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/15/25.

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var query = ""
    @FocusState private var isFocused: Bool

    // MARK: - Filtered Events
    private var filtered: [Event] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let events = eventStore.events
        guard !q.isEmpty else { return events }
        return events.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))

                        TextField("Search events or places", text: $query)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                            .focused($isFocused)

                        if !query.isEmpty {
                            Button {
                                query = ""
                                isFocused = true
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // MARK: - Search Results / Empty State
                    if filtered.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))

                            Text(query.isEmpty
                                 ? "Try searching for parties, teams, houses, or venues."
                                 : "No results for “\(query)”")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.65))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filtered) { event in
                                NavigationLink {
                                    EventDetailView(event: event)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        // MARK: - Title and Date Row
                                        HStack(alignment: .top, spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(event.title)
                                                    .font(.headline)
                                                    .foregroundColor(.white)

                                                Text(event.date, style: .date)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white.opacity(0.35))
                                                .font(.system(size: 14, weight: .semibold))
                                        }

                                        // MARK: - RSVP + Votes Row
                                        HStack(spacing: 16) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "person.2.fill")
                                                    .foregroundColor(.white.opacity(0.6))
                                                    .font(.caption)
                                                Text("\(event.rsvps ?? 0) going")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                            }

                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.up.circle.fill")
                                                    .foregroundColor(.white.opacity(0.6))
                                                    .font(.caption)
                                                let netVotes = (event.upvote_count ?? 0) - (event.downvote_count ?? 0)
                                                Text("\(netVotes)")
                                                    .font(.caption)
                                                    .foregroundColor(netVotes >= 0 ? .white.opacity(0.7) : .red.opacity(0.8))
                                            }
                                        }
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .environmentObject(EventStore())
            .preferredColorScheme(.dark)
    }
}
