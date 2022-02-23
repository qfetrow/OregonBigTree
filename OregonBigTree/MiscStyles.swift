//
//  MiscStyles.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/28/22.
//

let green = Color(red:0.71, green:0.9, blue:0.74)
let red = Color(red:1.0, green:0.79, blue:0.59)
let blue = Color(red:0.67, green:0.6, blue:0.95)

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

struct RoundedRectangleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button(action: {}, label: {
      HStack {
        Spacer()
        configuration.label.foregroundColor(.white)
        Spacer()
      }
    })
    .allowsHitTesting(false)
    .padding(12)
    .background(Color.gray.cornerRadius(8))
    .scaleEffect(configuration.isPressed ? 0.95 : 1)
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
    
    func htmlnotationConvert() -> String {
        let new = self.withReplacedCharacters("<b>", by: "**")
        let new2 = new.withReplacedCharacters("</b>", by: "**")
        let new3 = new2.withReplacedCharacters("<i>", by: "_")
        let new4 = new3.withReplacedCharacters("</i>", by: "_")
        return new4
    }
    
    func convertDate() -> String {
        // Dates are formatted weird in the legistlative api, this fixes them
        let new = self.components(separatedBy: "T")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"

        if let date = dateFormatterGet.date(from: new[0]) {
            return dateFormatterPrint.string(from: date)
        } else {
            print("Error decoding date: \(self)")
           return self
        }
        
    }
}

extension UIColor {

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

