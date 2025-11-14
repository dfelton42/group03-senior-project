//
//  SearchView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/15/25.
//

import SwiftUI

struct SearchView: View {
    let allEvents: [Event]

    @State private var query = ""
    @FocusState private var isFocused: Bool

    // Filter events by title
    private var filtered: [Event] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return allEvents }
        return allEvents.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Custom rounded search bar
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

                    // Search results or placeholder text
                    if filtered.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            Text(query.isEmpty ? "Try searching for parties, teams, houses, or venues." :
                                 "No results for “\(query)”")
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
        .onAppear { isFocused = true }
    }
}

