//
//  HomeView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/15/25.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var selectedCategory: EventCategory = .all

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            if eventStore.isLoading {
                loadingState
            } else if eventStore.events.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // CATEGORY CHIPS
                        categoryChips

                        // TRENDING SECTION
                        if !featuredEvents.isEmpty {
                            trendingSection
                        }

                        // MAIN FEED
                        if !filteredEvents.isEmpty {
                            Text(allEventsHeader)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 16)

                            LazyVStack(spacing: 26) {
                                ForEach(filteredEvents) { event in
                                    eventCard(event)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .padding(.top, 4)
                        } else {
                            Text("No \(selectedCategory.displayName.lowercased()) events right now.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 14)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Color("AppBackground").ignoresSafeArea())
    }

    // MARK: - Derived Data
    private var categorizedEvents: [(event: Event, category: EventCategory)] {
        eventStore.events.map { ($0, EventCategory.forEvent($0)) }
    }

    private var filteredEvents: [Event] {
        if selectedCategory == .all {
            return eventStore.events.sorted { $0.date < $1.date }
        }
        return categorizedEvents
            .filter { $0.category == selectedCategory }
            .map { $0.event }
            .sorted { $0.date < $1.date }
    }

    private var featuredEvents: [Event] {
        let base = filteredEvents.isEmpty ? eventStore.events : filteredEvents
        let sorted = base.sorted { lhs, rhs in
            let lhsR = lhs.rsvps ?? 0
            let rhsR = rhs.rsvps ?? 0
            if lhsR == rhsR {
                return lhs.date > rhs.date
            }
            return lhsR > rhsR
        }
        return Array(sorted.prefix(6))
    }

    private var allEventsHeader: String {
        selectedCategory == .all ? "All Events" : "All \(selectedCategory.displayName) Events"
    }

    // MARK: - Loading & Empty States
    var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color("AccentColor"))
            Text("Loading events…")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.4))
            Text("No events found")
                .font(.title3.bold())
                .foregroundColor(.white)
            Text("Check back soon — new events update automatically.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 80)
    }

    // MARK: - Category Chips
    var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(EventCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 6) {
                            if let icon = category.icon {
                                Image(systemName: icon)
                            }
                            Text(category.displayName)
                        }
                        .font(.subheadline.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == category
                            ? Color.white.opacity(0.18)
                            : Color.white.opacity(0.06)
                        )
                        .foregroundColor(.white.opacity(selectedCategory == category ? 1.0 : 0.75))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    selectedCategory == category
                                    ? Color.white.opacity(0.7)
                                    : Color.white.opacity(0.12),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Trending Section
    var trendingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Trending Now")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.95))
                Spacer()
                Text("Top \(featuredEvents.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(featuredEvents) { event in
                                    trendingCard(event)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }

                // MARK: - Trending Card
                func trendingCard(_ e: Event) -> some View {
                    NavigationLink {
                        EventDetailView(event: e)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.8), .pink.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(e.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .lineLimit(2)

                                        Text(e.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                )
                                .frame(width: 220, height: 120)

                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange.opacity(0.9))
                                    .font(.caption)

                                Text("\(e.rsvps ?? 0) going")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Main Event Card (Vertical Feed)
                func eventCard(_ e: Event) -> some View {
                    NavigationLink {
                        EventDetailView(event: e)
                    } label: {
                        VStack(alignment: .leading, spacing: 14) {

                            // HEADER
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.75), .purple.opacity(0.75)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(e.title)
                                            .font(.title2.bold())
                                            .foregroundColor(.white)
                                            .shadow(radius: 6)

                                        Text(e.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                )
                                .frame(height: 160)
                                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 5)

                            // DESCRIPTION AREA
                            VStack(alignment: .leading, spacing: 6) {
                                Text(e.description)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineLimit(3)

                                HStack(spacing: 12) {
                                    // RSVP COUNT
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.2.fill")
                                            .foregroundColor(.white.opacity(0.6))
                                        Text("\(e.rsvps ?? 0) RSVPs")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.caption)
                                    }

                                    // UPVOTES
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .foregroundColor(.white.opacity(0.6))
                                        let netVotes = (e.upvote_count ?? 0) - (e.downvote_count ?? 0)
                                        Text("\(netVotes)")
                                            .font(.caption)
                                            .foregroundColor(netVotes >= 0 ? .white.opacity(0.7) : .red.opacity(0.8))
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                }
            }

            #Preview {
                NavigationStack {
                    HomeView()
                        .environmentObject(EventStore())
                        .preferredColorScheme(.dark)
                }
            }
