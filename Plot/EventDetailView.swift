//
//  EventDetailView.swift
//  Plot
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

    @State private var attendingEvent: Bool = false
    @State private var isLoadingRsvp: Bool = true

    @State private var voteCount: Int = 0
    @State private var userVoteStatus: VoteAction = .none
    @State private var isLoadingVotes: Bool = true

    init(event: Event) {
        self.event = event
        _region = State(initialValue: MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    // MARK: - Voting Logic
    private func updateVote(action: VoteAction) {
        let oldUserVoteStatus = userVoteStatus
        var delta = 0

        Task {
            do {
                var newVoteStatus = action

                if userVoteStatus == action {
                    newVoteStatus = .none
                    delta = (action == .upvote ? -1 : 1)

                } else {
                    if userVoteStatus == .upvote {
                        delta = (action == .downvote ? -2 : 0)
                    } else if userVoteStatus == .downvote {
                        delta = (action == .upvote ? 2 : 0)
                    } else {
                        delta = (action == .upvote ? 1 : -1)
                    }
                }

                voteCount += delta
                userVoteStatus = newVoteStatus
                
                try await SupabaseManager.shared.updateUserVoteStatus(
                    eventId: event.id,
                    voteAction: newVoteStatus
                )

            } catch {
                voteCount -= delta
                userVoteStatus = oldUserVoteStatus
            }
        }
    }

    // MARK: - View Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Title + Voting
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.largeTitle.bold())

                        Text(event.date, style: .date)
                            .font(.headline)
                    }

                    Spacer()

                    if isLoadingVotes {
                        ProgressView()
                            .padding(.trailing, 20)
                    } else {
                        VStack(spacing: 4) {
                            Button {
                                updateVote(action: .upvote)
                            } label: {
                                Image(systemName: "chevron.up")
                                    .font(.title)
                                    .foregroundColor(userVoteStatus == .upvote ? .blue : .gray)
                            }

                            Text("\(voteCount)")
                                .font(.headline)

                            Button {
                                updateVote(action: .downvote)
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title)
                                    .foregroundColor(userVoteStatus == .downvote ? .red : .gray)
                            }
                        }
                    }
                }

                Divider()

                Text(event.description)
                    .font(.body)

                Divider()

                Map(coordinateRegion: $region, annotationItems: [event]) { event in
                    MapMarker(coordinate: event.coordinate, tint: .blue)
                }
                .frame(height: 250)
                .cornerRadius(12)

                Spacer()

                if isLoadingRsvp {
                    ProgressView("Checking RSVP...")
                        .frame(maxWidth: .infinity)
                } else if attendingEvent {
                    Button("Cancel RSVP") {
                        Task {
                            attendingEvent = false
                            try? await SupabaseManager.shared.removeRsvp(eventId: event.id)
                        }
                    }
                    .modifier(SecondaryButtonStyle())
                    .padding(.horizontal, 20)
                } else {
                    Button("I'm going") {
                        Task {
                            attendingEvent = true
                            try? await SupabaseManager.shared.addRsvp(eventId: event.id)
                        }
                    }
                    .modifier(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {

            // LOAD USER ACTIONS
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

                attendingEvent = isAttending

                // MARK: - FIXED: Safe calculation using new fields
                voteCount = (event.upvoteCount ?? 0) - (event.downvoteCount ?? 0)

            } catch {
                attendingEvent = false
            }

            isLoadingRsvp = false
            isLoadingVotes = false
        }
    }
}

// MARK: - Helper
func getUserActionStatuses(for eventID: UUID) async throws
    -> (isDownvoting: Bool, isUpvoting: Bool, isAttending: Bool)
{
    let records = try await SupabaseManager.shared.fetchUserEventActions(eventId: eventID)

    guard let record = records.first else {
        return (false, false, false)
    }

    let downvoteValue = record["is_downvoting"] as? Int ?? 0
    let upvoteValue = record["is_upvoting"] as? Int ?? 0
    let attendingValue = record["is_attending"] as? Int ?? 0

    return (
        isDownvoting: downvoteValue == 1,
        isUpvoting: upvoteValue == 1,
        isAttending: attendingValue == 1
    )
}
