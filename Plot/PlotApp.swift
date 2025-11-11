//
//  PlotApp.swift
//  Plot
//
//  Created by Julian Mazzier on 9/19/25.
//
import SwiftUI

@main
struct PlotApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
