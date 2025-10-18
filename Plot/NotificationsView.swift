//
//  NotificationsView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/15/25.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        List {
            ForEach(sampleNotifications, id: \.self) { note in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color("AccentColor"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note)
                            .foregroundColor(.white)
                        Text("Just now")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.vertical, 6)
                .listRowBackground(Color.white.opacity(0.06))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private let sampleNotifications = [
    "Jersey Night just added new details.",
    "Gamma House BBQ starts in 1 hour.",
    "Your RSVP for Sigma Bash was confirmed."
]
