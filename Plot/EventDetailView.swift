//
//  EventDetailView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI
import MapKit

// Voting enum from Jeron's branch
enum VoteAction {
    case upvote
    case downvote
    case none
}

struct EventDetailView: View {
    let event: Event

    @State private var region: MKCoordinateRegion
    @State private var attending = false
    @State private var checkingRsvp = true

    // Voting state
    @State private var voteCount: Int = 0
    @State private var userVoteStatus: VoteAction = .none
    @State private var isLoadingVotes: Bool = true

    @StateObject private var locationManager = LocationManager()

    init(event: Event) {
        self.event = event
        _region = State(initialValue: MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    // MARK: - Voting Logic

    private func updateVote(action: VoteAction) {
        let previousStatus = userVoteStatus
        var delta = 0

        Task {
            do {
                var newStatus: VoteAction = action

                // If user taps the same vote again, remove their vote
                if userVoteStatus == action {
                    newStatus = .none
                    delta = (action == .upvote ? -1 : 1)
                } else {
                    // Switching or setting vote
                    switch (userVoteStatus, action) {
                    case (.upvote, .downvote):
                        delta = -2      // +1 -> -1
                    case (.downvote, .upvote):
                        delta = 2       // -1 -> +1
                    case (.none, .upvote):
                        delta = 1
                    case (.none, .downvote):
                        delta = -1
                    default:
                        delta = 0
                    }
                }

                voteCount += delta
                userVoteStatus = newStatus

                try await SupabaseManager.shared.updateUserVoteStatus(
                    eventId: event.id,
                    voteAction: newStatus
                )
            } catch {
                // Roll back on failure
                voteCount -= delta
                userVoteStatus = previousStatus
                print("❌ updateVote failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Title + Vote Control
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.title.bold())
                            .foregroundColor(.white)

                        Text(event.date, style: .date)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    if isLoadingVotes {
                        ProgressView()
                            .tint(Color("AccentColor"))
                    } else {
                        VStack(spacing: 4) {
                            Button {
                                updateVote(action: .upvote)
                            } label: {
                                Image(systemName: "chevron.up")
                                    .font(.title2)
                                    .foregroundColor(userVoteStatus == .upvote ? .blue : .gray)
                            }
                            .buttonStyle(.plain)

                            Text("\(voteCount)")
                                .font(.headline)
                                .foregroundColor(.white)

                            Button {
                                updateVote(action: .downvote)
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title2)
                                    .foregroundColor(userVoteStatus == .downvote ? .red : .gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Divider().background(Color.white.opacity(0.1))

                Text(event.description)
                    .foregroundColor(.white.opacity(0.9))

                Divider().background(Color.white.opacity(0.1))

                Map(position: .constant(.region(region))) {
                    Annotation(event.title, coordinate: event.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(Color("AccentColor"))
                            .shadow(radius: 3)
                    }
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.07))
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)

                // RSVP section
                if checkingRsvp {
                    ProgressView("Checking RSVP…")
                        .tint(Color("AccentColor"))
                } else if attending {
                    Button("Cancel RSVP") {
                        Task {
                            do {
                                try await SupabaseManager.shared.removeRsvp(eventId: event.id)
                                attending = false

                                // ✅ Post after DB finishes — on main actor
                                await MainActor.run {
                                    NotificationCenter.default.post(name: .eventsDidChange, object: nil)
                                }

                            } catch {
                                print("❌ cancel RSVP:", error.localizedDescription)
                            }
                        }
                    }
                    .modifier(PrimaryButtonStyle(backgroundColor: .white, foregroundColor: .black))
                } else {
                    Button("I’m going") {
                        Task {
                            do {
                                try await SupabaseManager.shared.addRsvp(eventId: event.id)
                                attending = true

                                // ✅ Post after DB finishes — on main actor
                                await MainActor.run {
                                    NotificationCenter.default.post(name: .eventsDidChange, object: nil)
                                }

                            } catch {
                                print("❌ add RSVP:", error.localizedDescription)
                            }
                        }
                    }
                    .primaryCTA()
                }

                // MARK: - USER LOCATION SECTION
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Location:")
                        .font(.headline)
                        .foregroundColor(.white)

                    if locationManager.isAuthorized {
                        if let loc = locationManager.userLocation {
                            Text("Lat: \(loc.latitude), Lon: \(loc.longitude)")
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            Text("Locating…")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Text("Location access not granted.")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.top, 12)
            }
            .padding(16)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            // Request location right away
            locationManager.requestLocation()

            // Fetch user action status (RSVP + votes)
            do {
                let (isDownvoting, isUpvoting, isAttending) =
                    try await getUserActionStatuses(for: event.id)

                if isUpvoting {
                    userVoteStatus = .upvote
                } else if isDownvoting {
                    userVoteStatus = .downvote
                } else {
                    userVoteStatus = .none
                }

                attending = isAttending

                // Use optionals safely, defaulting to 0
                let up = event.upvote_count ?? 0
                let down = event.downvote_count ?? 0
                voteCount = up - down
            } catch {
                attending = false
                userVoteStatus = .none
                print("❌ getUserActionStatuses:", error.localizedDescription)
            }

            checkingRsvp = false
            isLoadingVotes = false
        }
    }
}

// Helper: uses SupabaseManager.fetchUserEventActions
func getUserActionStatuses(for eventID: UUID) async throws
    -> (isDownvoting: Bool, isUpvoting: Bool, isAttending: Bool)
{
    let actionRecords: [[String: Any]] =
        try await SupabaseManager.shared.fetchUserEventActions(eventId: eventID)

    guard let record = actionRecords.first else {
        return (isDownvoting: false, isUpvoting: false, isAttending: false)
    }

    let downvoteValue = record["is_downvoting"] as? Int ?? 0
    let upvoteValue = record["is_upvoting"] as? Int ?? 0
    let attendingValue = record["is_attending"] as? Int ?? 0

    let isDownvoting = downvoteValue == 1
    let isUpvoting = upvoteValue == 1
    let isAttending = attendingValue == 1

    return (isDownvoting: isDownvoting, isUpvoting: isUpvoting, isAttending: isAttending)
}
