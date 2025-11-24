//
//  EventDetailView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI
import MapKit

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

    @State private var voteCount = 0
    @State private var userVoteStatus: VoteAction = .none
    @State private var isLoadingVotes = true

    @StateObject private var locationManager = LocationManager()

    @State private var driveTime: String?
    @State private var walkTime: String?
    @State private var isLoadingTravel = true

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
                var newStatus = action

                if userVoteStatus == action {
                    newStatus = .none
                    delta = (action == .upvote ? -1 : 1)
                } else {
                    switch (userVoteStatus, action) {
                    case (.upvote, .downvote):
                        delta = -2
                    case (.downvote, .upvote):
                        delta = 2
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
                voteCount -= delta
                userVoteStatus = previousStatus
                print("❌ updateVote failed:", error.localizedDescription)
            }
        }
    }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Title + Voting
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
                    }
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 6)

                // RSVP SECTION
                if checkingRsvp {
                    ProgressView("Checking RSVP…")
                        .tint(Color("AccentColor"))
                } else if attending {
                    Button("Cancel RSVP") {
                        Task {
                            do {
                                try await SupabaseManager.shared.removeRsvp(eventId: event.id)
                                attending = false
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
                            } catch {
                                print("❌ add RSVP:", error.localizedDescription)
                            }
                        }
                    }
                    .primaryCTA()
                }

                // LOCATION + TRAVEL
                VStack(alignment: .leading, spacing: 10) {

                    Text("Google Maps Travel Estimates")
                        .font(.headline)
                        .foregroundColor(.white)

                    if isLoadingTravel {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(Color("AccentColor"))

                            Text("Calculating…")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)

                    } else {
                        VStack(alignment: .leading, spacing: 6) {

                            if let driveTime {
                                HStack(spacing: 8) {
                                    Image(systemName: "car.fill")
                                        .foregroundColor(.white.opacity(0.7))

                                    Text(driveTime)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }

                            if let walkTime {
                                HStack(spacing: 8) {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(.white.opacity(0.7))

                                    Text(walkTime)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(16)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .task {
            locationManager.requestLocation()

            // User Action Statuses
            do {
                let (down, up, attendingStatus) =
                    try await getUserActionStatuses(for: event.id)

                if up { userVoteStatus = .upvote }
                else if down { userVoteStatus = .downvote }
                else { userVoteStatus = .none }

                attending = attendingStatus

                let upCount = event.upvote_count ?? 0
                let downCount = event.downvote_count ?? 0
                voteCount = upCount - downCount

            } catch {}

            checkingRsvp = false
            isLoadingVotes = false

            // Travel Est.
            if let loc = locationManager.userLocation {
                Task {
                    isLoadingTravel = true

                    let (drive, walk) = try await SupabaseManager.shared.fetchTravelEstimates(
                        startLat: loc.latitude,
                        startLng: loc.longitude,
                        endLat: event.coordinate.latitude,
                        endLng: event.coordinate.longitude
                    )

                    driveTime = drive
                    walkTime = walk

                    isLoadingTravel = false
                }
            }
        }
        .onChange(of: locationManager.userLocation?.latitude) {
            if let loc = locationManager.userLocation {
                Task {
                    isLoadingTravel = true

                    let (drive, walk) = try await SupabaseManager.shared.fetchTravelEstimates(
                        startLat: loc.latitude,
                        startLng: loc.longitude,
                        endLat: event.coordinate.latitude,
                        endLng: event.coordinate.longitude
                    )

                    driveTime = drive
                    walkTime = walk

                    isLoadingTravel = false
                }
            }
        }
    }
}



// Helper
func getUserActionStatuses(for eventID: UUID) async throws
-> (Bool, Bool, Bool)
{
    let rows = try await SupabaseManager.shared.fetchUserEventActions(eventId: eventID)

    guard let row = rows.first else {
        return (false, false, false)
    }

    return (
        (row["is_downvoting"] as? Int ?? 0) == 1,
        (row["is_upvoting"] as? Int ?? 0) == 1,
        (row["is_attending"] as? Int ?? 0) == 1
    )
}

