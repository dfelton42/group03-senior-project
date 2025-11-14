//
//  ViewStyles.swift
//  Plot
//
//  Created by Jeron Alford on 10/6/25.
//

import SwiftUI

// MARK: - AUTH INPUT FIELD STYLE
struct AuthInputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .cornerRadius(12)
            .font(.body)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .foregroundColor(.white)
    }
}

// MARK: - PRIMARY BUTTON STYLE
struct PrimaryButtonStyle: ViewModifier {
    var backgroundColor: Color = Color("AccentColor")
    var foregroundColor: Color = .white
    
    func body(content: Content) -> some View {
        content
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .shadow(color: backgroundColor.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

// MARK: - SECONDARY BUTTON STYLE
struct SecondaryButtonStyle: ViewModifier {
    var backgroundColor: Color = .clear
    var foregroundColor: Color = .white
    var borderColor: Color = .white.opacity(0.5)
    var borderWidth: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

// MARK: - AUTH SCAFFOLD
struct AuthScaffold<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            
            VStack(spacing: 26) {
                Spacer(minLength: 24)
                
                if let title {
                    Text(title)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                }
                
                content
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - VIEW EXTENSIONS (GLOBAL HELPERS)
extension View {
    func authField() -> some View { modifier(AuthInputFieldStyle()) }
    func primaryCTA() -> some View { modifier(PrimaryButtonStyle()) }
    func secondaryCTA() -> some View { modifier(SecondaryButtonStyle()) }
    
    func muted() -> some View {
        self.foregroundColor(Color.white.opacity(0.6))
    }
}
