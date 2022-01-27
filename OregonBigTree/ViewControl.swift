//
//  ViewControl.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/26/22.
//

import SwiftUI
import Foundation

struct ViewControl: View {
    var body: some View {
        TabView {
            RepsByAddressView().tabItem() {
                Image(systemName: "person.circle")
                Text("Your Reps")
            }
        }
    }
}

