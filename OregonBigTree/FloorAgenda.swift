//
//  FloorAgenda.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 2/22/22.
//

import SwiftUI
import Foundation

class FloorData: ObservableObject {
    // This reads all measure data from the api into measure objects
    private let seshkey: String
    private let chamber: String
    @Published var agdict: [String: [FloorSessionAgendaItem]] = [:]
    @Published var senateitems: [FloorSessionAgendaItem] = [] // Update each time the legislator data is updated
    @Published var houseitems: [FloorSessionAgendaItem] = []
    @Published var dataread: Bool = false
    
    init(seshkey: String, chamber: String) {
        self.seshkey = seshkey
        self.chamber = chamber
    }
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/FloorSessionAgendaItems?$format=json&$orderby=ScheduleDate&$filter=ScheduleDate%20gt%20DateTime%272022-03-03T11:39:32%27%20and%20SessionKey%20eq%20%27\(seshkey)%27%20and%20Chamber%20eq%20%27\(chamber)%27") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }

            do {
                let initial = try JSONDecoder().decode(InitialFloor.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    for agitem in initial.value {
                        self?.dataread = true
                        if agitem.OrderOfBusiness.lowercased().contains("third") {
                            if !(self?.houseitems.contains(agitem) ?? false) {
                                self?.houseitems.append(agitem)
                            }
                        }
                    }
                    if let a = self?.houseitems {
                        self?.agdict = a.sortbydate()
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


struct FloorView: View {
    @StateObject var fdata: FloorData
    @State var agdict: [String: [FloorSessionAgendaItem]] = [:]
    init(chamberkey: String, sesskey: String) {
        _fdata = StateObject(wrappedValue: FloorData(seshkey: sesskey, chamber: chamberkey))
    }
    var body: some View {
        List {
            let agdict = fdata.agdict
            let keys = agdict.map{$0.key}
            let values = agdict.map {$0.value}
            ForEach(keys.indices, id: \.self) { index in
                Section(header: Text(keys[index].convertDate())
                            .font(.title2)
                            .bold()
                            .foregroundColor(blue)) {
                    ForEach(values[index], id: \.self) { agitem in
                        VStack (alignment: .leading) {
                            SingleFromPrefixNumber(mnumber: agitem.MeasureNumber, mprefix: agitem.MeasurePrefix)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear() {
            if !(fdata.dataread) {
                print("READING")
                fdata.fetch()
            }
        }
    }
}
