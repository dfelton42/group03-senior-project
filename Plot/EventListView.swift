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
            VStack(spacing: 12) {
                ForEach(events) { event in
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
                                .stroke(Color.white.opacity(0.07))
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color("AppBackground").ignoresSafeArea())
    }
}
