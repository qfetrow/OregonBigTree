//
//  CommitteeMeeting.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 3/1/22.
//

import Foundation
import SwiftUI

class CommitteeMItemData: ObservableObject {
    let committeecode: String
    let sessionkey: String
    let meetingdate: String
    @Published var dataRead: Bool = false
    @Published var fullcomments: String = ""
    @Published var mitems: [CommitteeAgendaItem] = []
    init(ccode: String, skey: String, mdate: String) {
        self.committeecode = ccode
        self.sessionkey = skey
        self.meetingdate = mdate
    }
    
    func fetch() {
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/CommitteeAgendaItems?$format=json&$filter=MeetingDate%20gt%20DateTime%27\(meetingdate)%27&$orderby=MeetingDate%20desc") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }
            do {
                let initial = try JSONDecoder().decode(InitialCommitteeItem.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    self?.dataRead = true
                    for mitem in initial.value {
                        if mitem.MeasureNumber != nil {
                            self?.mitems.append(mitem)
                        } else {
                            if let a = mitem.Comments {
                                self?.fullcomments += "<br>" + a
                            }
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

class CommitteeMeetingData: ObservableObject {
    @Published var dataRead: Bool = false
    @Published var meetings: [CommitteeMeeting] = []
    
    func fetch() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let now = dateFormatter.string(from: Date.now)
        print(now)
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/CommitteeMeetings?$format=json&$filter=MeetingDate%20gt%20DateTime%27\("2022-03-01T15:15:00")%27&$orderby=MeetingDate") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }
            do {
                let initial = try JSONDecoder().decode(InitialCommitteeMeeting.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    self?.meetings = initial.value
                    self?.dataRead = true
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct CommitteeMItemView: View {
    @StateObject private var dataModel: CommitteeMItemData
    @State var commentstring: String = ""
    init(comcode: String, seshkey: String, meetingdate: String) {
        _dataModel = StateObject(wrappedValue: CommitteeMItemData(ccode: comcode, skey: seshkey, mdate: meetingdate))
    }
    var body: some View {
        VStack {
            List {
                if(dataModel.mitems != []) {
                    ForEach(dataModel.mitems, id: \.self) { mitem in
                        // Lots of unwrapping here haha
                        if let a = mitem.MeasurePrefix {
                            if let b = mitem.MeasureNumber {
                                if let c = mitem.MeetingType {
                                    VStack (alignment: .leading) {
                                        Text(c)
                                            .bold()
                                        SingleFromPrefixNumber(mnumber: b, mprefix: a)
                                    }
                                    .padding(0)
                                }
                            }
                        }
                    }
                }
            }
                .listStyle(PlainListStyle())
                    .navigationBarTitle(Text("On the Agenda"))
        }
        .onAppear {
            if (!dataModel.dataRead) {
                dataModel.fetch()
            }
        }
    }
}

struct CommitteeMeetingView: View {
    @StateObject private var dataModel: CommitteeMeetingData = CommitteeMeetingData()
    var body: some View {
        NavigationView {
            List {
                ForEach(dataModel.meetings, id: \.self) { meeting in
                    NavigationLink {
                        CommitteeMItemView(comcode: meeting.CommitteeCode, seshkey: meeting.SessionKey, meetingdate: meeting.MeetingDate)
                    } label: {
                        VStack (alignment: .leading) {
                            Text(meeting.MeetingDate.convertDate())
                                .bold()
                            Text(meeting.CommitteeCode)
                        }
                    }
                }
            }
        }
        .onAppear {
            dataModel.fetch()
        }
    }
}

