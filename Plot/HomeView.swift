//
//  HomeView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/15/25.
//

import SwiftUI

struct HomeView: View {
    let events: [Event]
    let isLoading: Bool

    @State private var selectedCategory: EventCategory = .all

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            if isLoading {
                loadingState
            } else if events.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // CATEGORY CHIPS
                        categoryChips

                        // TRENDING CAROUSEL
                        if !featuredEvents.isEmpty {
                            trendingSection
                        }

                        // MAIN FEED
                        if !filteredEvents.isEmpty {
                            Text("All \(selectedCategory.displayName) Events")
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
        events.map { ($0, EventCategory.forEvent($0)) }
    }

    private var filteredEvents: [Event] {
        if selectedCategory == .all {
            return events.sorted { $0.date < $1.date }
        }
        return categorizedEvents
            .filter { $0.category == selectedCategory }
            .map { $0.event }
            .sorted { $0.date < $1.date }
    }

    // Trending: highest RSVPs within selected category (or all)
    private var featuredEvents: [Event] {
        let base = filteredEvents.isEmpty ? events : filteredEvents
        return base
            .sorted { $0.rsvps > $1.rsvps }
            .prefix(6)
            .map { $0 }
    }

    // MARK: - Loading
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

    // MARK: - Empty State
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

                    Text("\(e.rsvps) going")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.06))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 5)
            .safePressAnimation()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Main Event Card (Vertical Feed)

    func eventCard(_ e: Event) -> some View {
        NavigationLink {
            EventDetailView(event: e)
        } label: {
            VStack(alignment: .leading, spacing: 14) {

                // Premium Gradient Header
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

                // Description Area
                VStack(alignment: .leading, spacing: 6) {
                    Text(e.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(3)

                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(e.rsvps) RSVPs")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 4)

            }
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
            .safePressAnimation()
        }
        .buttonStyle(.plain)
    }
}


// MARK: - EventCategory

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

        if text.contains("party") || text.contains("afterparty") || text.contains("bash") || text.contains("mixer") || text.contains("kickoff") || text.contains("bonfire") {
            return .parties
        }
        if text.contains("hockey") || text.contains("basketball") || text.contains("soccer") ||
            text.contains("tennis") || text.contains("softball") || text.contains("lacrosse") ||
            text.contains("swim") {
            return .sports
        }
        if text.contains("alpha") || text.contains("beta") || text.contains("gamma") ||
            text.contains("delta") || text.contains("sigma") || text.contains("kappa") ||
            text.contains("zeta") {
            return .greek
        }
        if text.contains("concert") || text.contains("dj") || text.contains("music") || text.contains("band") {
            return .concerts
        }
        return .other
    }
}


// MARK: - Safe Tap Animation

fileprivate extension View {
    func safePressAnimation() -> some View {
        self.modifier(SafePressAnimation())
    }
}

fileprivate struct SafePressAnimation: ViewModifier {
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in state = true }
            )
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView(
            events: [
                Event(
                    id: UUID(),
                    title: "Beach Bonfire Bash",
                    description: "Join LMU students for a sunset bonfire with games, music, and s’mores.",
                    date: Date().addingTimeInterval(3600),
                    latitude: nil,
                    longitude: nil,
                    rsvps: 42
                ),
                Event(
                    id: UUID(),
                    title: "Hockey Night Afterparty",
                    description: "Celebrate with the LMU hockey team after the big win!",
                    date: Date().addingTimeInterval(7200),
                    latitude: nil,
                    longitude: nil,
                    rsvps: 87
                ),
                Event(
                    id: UUID(),
                    title: "Campus Concert",
                    description: "Live bands, food trucks, and a packed student crowd.",
                    date: Date().addingTimeInterval(10800),
                    latitude: nil,
                    longitude: nil,
                    rsvps: 120
                )
            ],
            isLoading: false
        )
    }
    .environmentObject(AuthViewModel())
}
