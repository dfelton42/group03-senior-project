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

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color("AccentColor"))
                    Text("Loading events…")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                EventListView(events: events)
                    .background(Color("AppBackground"))
            }
        }
    }
}
