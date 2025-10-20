//
//  EventListView.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI

struct EventListView: View {
    let events: [Event]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 48, height: 48)
                                
                            
                                Text("🎟️")
                                    .font(.system(size: 24))
                                
                                // note for later: I could change emoji to image
                                // Image("event_placeholder")
                                //     .resizable()
                                //     .scaledToFill()
                                //     .frame(width: 48, height: 48)
                                //     .clipShape(Circle())
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(event.title)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)

                                Text(event.date, style: .date)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color("AppBackground").ignoresSafeArea())
    }
}
