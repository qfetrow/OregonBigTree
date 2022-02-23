//
//  CommitteeChoice.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 2/18/22.
//

import SwiftUI
import Foundation

let currentsession: String = "2022R1"
class CommitteeData: ObservableObject {
    // This reads all measure data from the api into measure objects
    @Published var HouseCommittees: [Committee] = []
    @Published var SenateCommittees: [Committee] = []
    @Published var JointCommittees: [Committee] = []
    @Published var dataRead: Bool = false
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/Committees?$format=json&$filter=SessionKey%20eq%20%27\(currentsession)%27") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }

            do {
                let initial = try JSONDecoder().decode(InitialCommittee.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    for committee in initial.value {
                        self?.dataRead = true
                        if (committee.HouseOfAction == "H") {
                            self?.HouseCommittees.append(committee)
                        } else if (committee.HouseOfAction == "S") {
                            self?.SenateCommittees.append(committee)
                        } else {
                            self?.JointCommittees.append(committee)
                        }
                                
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()

    }
}

struct CommitteeChoice: View {
    @StateObject private var dataModel = CommitteeData()
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Senate Committees")
                            .font(.title2)
                            .bold()
                            .foregroundColor(green)) {
                    ForEach(dataModel.SenateCommittees, id: \.self) { committee in
                        VStack {
                            NavigationLink {
                                MeasureListView(committeeCode: committee.CommitteeCode, committeeString: committee.CommitteeName)
                            } label: {
                                Text(committee.CommitteeName)
                                    .padding(3)
                                    .font(.headline)
                            }
                        }
                    }
                }.textCase(nil)
                
                Section(header: Text("House Committees")
                            .font(.title2)
                            .bold()
                            .foregroundColor(blue)) {
                    ForEach(dataModel.HouseCommittees, id: \.self) { committee in
                        VStack {
                            NavigationLink {
                                MeasureListView(committeeCode: committee.CommitteeCode, committeeString: committee.CommitteeName)
                            } label: {
                                Text(committee.CommitteeName)
                                    .padding(3)
                                    .font(.headline)
                            }
                        }
                    }
                }.textCase(nil)
                Section(header: Text("Joint Committees")
                            .font(.title2)
                            .bold()
                            .foregroundColor(red)) {
                    ForEach(dataModel.JointCommittees, id: \.self) { committee in
                        VStack {
                            NavigationLink {
                                MeasureListView(committeeCode: committee.CommitteeCode, committeeString: committee.CommitteeName)
                            } label: {
                                Text(committee.CommitteeName)
                                    .padding(3)
                                    .font(.headline)
                            }
                        }
                    }
                }.textCase(nil)
            }.listStyle(GroupedListStyle())
                .navigationBarHidden(true)
        }
        .onAppear {
            if (dataModel.dataRead == false) {
                dataModel.fetch()
            }
        }
    }
}
