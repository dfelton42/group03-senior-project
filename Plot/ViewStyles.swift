//
//  ViewStyles.swift
//  Plot
//
//  Created by Jeron Alford on 10/6/25.
//
import SwiftUI

// MARK: - Reusable Styles


struct AuthInputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 1)
            )
            .font(.body)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    var backgroundColor: Color = Color.purple 
    var foregroundColor: Color = .white
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
    }
}
struct SecondaryButtonStyle: ViewModifier {
    var backgroundColor: Color = Color.white
    var foregroundColor: Color = .black
    var borderColor: Color = .black
    var borderWidth: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}
