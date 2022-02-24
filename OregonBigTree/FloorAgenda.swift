//
//  FloorAgenda.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 2/22/22.
//

import SwiftUI
import Foundation

func measuregetter(mprefix: String, mnumber: Int) -> Measure? {
    var measuredocs: [Measure?] = [nil]
    guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/Measures?$format=json&$filter=MeasurePrefix%20eq%20%27\(mprefix)%27%20and%20MeasureNumber%20eq%20\(mnumber)&$orderby=CreatedDate%20desc") else {
        return nil
        }
    let task = URLSession.shared.dataTask(with: url) { data, _,
        error in
        guard let data = data, error == nil else {
            return // no data
        }
        do {
            let initial = try JSONDecoder().decode(InitialODATA.self, from: data)
            DispatchQueue.main.async {
                measuredocs = initial.value
            }
        }
        
        catch {
            print(error)
        }
    }
    task.resume()
    return measuredocs[0]
}

class FloorData: ObservableObject {
    // This reads all measure data from the api into measure objects
    private let committeecode: String
    @Published var senateitems: [FloorSessionAgendaItem] = [] // Update each time the legislator data is updated
    @Published var houseitems: [FloorSessionAgendaItem] = []
    @Published var dataread: Bool = false
    
    init(commitcode: String) {
        self.committeecode = commitcode
    }
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/FloorSessionAgendaItems?$format=json&$orderby=ScheduleDate%20desc&$filter=Completed%20eq%20false%20and%20SessionKey%20eq%20%27\(committeecode)%27") else {
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
                        if (agitem.Chamber == "H") {
                            self?.houseitems.append(agitem)
                        } else if (agitem.Chamber == "S") {
                            self?.senateitems.append(agitem)
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


struct FloorView: View {
    @StateObject var fdata: FloorData = FloorData(commitcode: "2022R1")
    var body: some View {
        List {
            Section(header: Text("Senate Votes Today")
                        .font(.title2)
                        .bold()
                        .foregroundColor(green)) {
                ForEach(fdata.senateitems, id: \.self) { agitem in
                    VStack (alignment: .leading){
                        Text(agitem.OrderOfBusiness)
                        
                        Text(verbatim: "\(agitem.MeasurePrefix)\(agitem.MeasureNumber)")
                    }
                }
            }
            Section(header: Text("House Votes Today")
                        .font(.title2)
                        .bold()
                        .foregroundColor(blue)) {
                ForEach(fdata.houseitems, id: \.self) { agitem in
                    NavigationLink {
                        if let measured = measuregetter(mprefix:agitem.MeasurePrefix, mnumber: agitem.MeasureNumber) {
                            ExpandedMeasureView(measure: measured)
                        }
                    } label: {
                        VStack (alignment: .leading){
                            Text(agitem.OrderOfBusiness)
                            
                            Text(verbatim: "\(agitem.MeasurePrefix)\(agitem.MeasureNumber)")
                        }
                    }
                }
            }
        }
        .onAppear() {
            if !fdata.dataread {
                fdata.fetch()
            }
        }
    }
}
