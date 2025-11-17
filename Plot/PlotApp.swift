//
//  PlotApp.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//

import SwiftUI

@main
struct PlotApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var eventStore = EventStore()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authVM)
                .environmentObject(eventStore)
        }
    }
}
