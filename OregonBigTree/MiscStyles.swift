//
//  MiscStyles.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/28/22.
//

import Foundation
import SwiftUI
struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .background(
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            )
    }
}


struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.0 : 0.9)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
extension String {
    // Just a function for trimming whitespace
    func removeWhitespace() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    func removeTabs() -> String {
        return self.filter{ !"\t".contains($0) }
    }
    // Used to replace whitespace with "%20" for APi interaction
    func withReplacedCharacters(_ oldChar: String, by newChar: String) -> String {
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
    }
}
