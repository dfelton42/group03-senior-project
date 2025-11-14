//
//  EventDetailView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI
import MapKit

// Assuming VoteAction is defined elsewhere (e.g., in SupabaseManager or a utility file)
enum VoteAction {
    case upvote
    case downvote
    case none
}

struct EventDetailView: View {
    let event: Event
    
    @State private var region: MKCoordinateRegion
    
    
    // MARK: - RSVP State
    @State private var attendingEvent: Bool = false
    @State private var isLoadingRsvp: Bool = true
    
    // MARK: - Voting State
    @State private var voteCount: Int = 0
    @State private var userVoteStatus: VoteAction = VoteAction.none
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
                var newVoteStatus: VoteAction = action
                
                // user clicks same vote action as they previously had, indicating they want to remove their vote action
                if userVoteStatus == action {
                    newVoteStatus = VoteAction.none
                    delta = (action == .upvote ? -1 : 1)
                } else {
                    // User is voting or switching votes
                    if userVoteStatus == .upvote {
                        // Switching from upvote -> downvote (delta is -2)
                        delta = (action == .downvote ? -2 : 0)
                    } else if userVoteStatus == .downvote {
                      
                        delta = (action == .upvote ? 2 : 0)
                    } else {
                        // No previous vote -> new vote (delta is +1 or -1)
                        delta = (action == .upvote ? 1 : -1)
                    }
                }
                
                voteCount += delta
                userVoteStatus = newVoteStatus
                try await SupabaseManager.shared.updateUserVoteStatus(eventId: event.id, voteAction: newVoteStatus)
                
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
                
                // MARK: Title and Voting Section
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.largeTitle)
                            .bold()
                        
                        Text(event.date, style: .date)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    // Vote Control (Upvote/Downvote Arrows)
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
                            .buttonStyle(.plain)
                            
                            Text("\(voteCount)")
                                .font(.headline)
                            
                            Button {
                                updateVote(action: .downvote)
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title)
                                    .foregroundColor(userVoteStatus == .downvote ? .red : .gray)
                            }
                            .buttonStyle(.plain)
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
                }
                else if attendingEvent {
                    Button("Cancel RSVP") {
                        Task {
                            do {
                                attendingEvent = false
                                try await SupabaseManager.shared.removeRsvp(eventId: event.id)
                            } catch {
                            }
                        }
                    }
                    .modifier(SecondaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                } else {
                    Button("I'm going") {
                        Task {
                            do {
                                attendingEvent = true
                                try await SupabaseManager.shared.addRsvp(eventId: event.id)
                            } catch {
                             
                            }
                        }
                    }
                    .modifier(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // MARK: Initial Data Fetch
            do {
                let (isDownvoting, isUpvoting, isAttending) = try await getUserActionStatuses(for: event.id)
                if isUpvoting {
                    userVoteStatus = VoteAction.upvote
                } else if isDownvoting {
                    userVoteStatus = VoteAction.downvote
                } else {
                    userVoteStatus = VoteAction.none
                }
                attendingEvent = isAttending
                voteCount = (event.upvote_count - event.downvote_count)
            } catch {
                attendingEvent = false // Assume not attending on error for simplicity
            }
            isLoadingRsvp = false
            isLoadingVotes = false
        }
    }
}

func getUserActionStatuses(for eventID: UUID) async throws -> (isDownvoting: Bool, isUpvoting: Bool, isAttending: Bool) {
    
    let actionRecords: [[String: Any]] = try await SupabaseManager.shared.fetchUserEventActions(eventId: eventID)
    
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
