//
//  SplashView.swift
//  Plot
//
//  Created by Christopher Chatel on 10/13/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity = 0.0

    var body: some View {
        ZStack {
            Color(red: 45/255, green: 21/255, blue: 67/255)
                .ignoresSafeArea()

            Image("PlotImage")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { isActive = true }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}
