//
//  MeasureViewSelect.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 3/3/22.
//

import SwiftUI
import Foundation

struct MeasureSelect: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    CommitteeChoice()
                } label: {
                    HStack {
                        Image(systemName: "person.3")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                        VStack (alignment: .leading) {
                            Text("Measures by Committee")
                                .bold()
                                .padding(.bottom, 1)
                            Text("Measures currently in a Senate, House, or Joint committee.")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                    }
                }
                .padding(.leading, 3)
                NavigationLink {
                    FloorView(chamberkey: "H", sesskey: "2022R1")
                } label: {
                    HStack {
                        Image(systemName: "house")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                        VStack (alignment: .leading) {
                            Text("Upcoming House Votes")
                                .bold()
                                .padding(.bottom, 1)
                            Text("Measures that will be voted on by the House of Representatives within the next few days.")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                    }
                }
                .padding(.leading, 3)
                NavigationLink {
                    FloorView(chamberkey: "S", sesskey: "2022R1")
                } label: {
                    HStack {
                        Image(systemName: "building")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20, height: 20)
                        VStack (alignment: .leading) {
                            Text("Upcoming Senate Votes")
                                .bold()
                                .padding(.bottom, 1)
                            Text("Measures that will be voted on by the State Senate within the next few days.")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                    }
                }
                .padding(.leading, 3)
            }
            .navigationTitle(Text("Measure Viewer"))
        }
    }
}
