//
//  LoginView.swift
//  Plot
//
//  Created by Jeron Alford on 10/6/25.
//

import SwiftUI

private let fieldBackground = Color.white.opacity(0.06)
private let fieldStroke = Color.white.opacity(0.08)

struct AuthInputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(fieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(fieldStroke, lineWidth: 1)
            )
            .cornerRadius(12)
            .font(.body)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundColor(.white)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    var backgroundColor: Color = Color("AccentColor")
    var foregroundColor: Color = .white

    func body(content: Content) -> some View {
        content
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .shadow(color: backgroundColor.opacity(0.3), radius: 10, x: 0, y: 6)
    }
}

struct AuthTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.largeTitle.bold())
            .foregroundColor(.white)
            .padding(.bottom, 8)
    }
}

struct AuthScaffold<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer(minLength: 16)
                if let title { AuthTitle(text: title) }
                content
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func authField() -> some View { modifier(AuthInputFieldStyle()) }
    func primaryCTA() -> some View { modifier(PrimaryButtonStyle()) }
    func muted() -> some View { self.foregroundColor(Color.white.opacity(0.7)) }
}
