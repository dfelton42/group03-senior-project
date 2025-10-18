//
//  SettingsView.swift
//  Plot
//
//  Created by Donovan Felton on 10/18/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("Settings Coming Soon")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
