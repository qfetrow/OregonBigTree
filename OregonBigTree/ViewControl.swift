//
//  ViewControl.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/26/22.
//

import SwiftUI
import Foundation

var Gaddress = "foo@bar.com"
struct ViewControl: View {
    var body: some View {
        TabView {
            RepsByAddressView().tabItem() {
                Image(systemName: "person.circle")
                Text("Your Reps")
            }
            MeasureListView().tabItem() {
                Image(systemName: "doc.plaintext")
                Text("Measures")
            }
        }
    }
}

