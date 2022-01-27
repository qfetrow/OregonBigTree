//
//  MeasureView.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/27/22.
//

import SwiftUI

class MeasureData: ObservableObject {
    // This reads all measure data from the api into measure objects
    @Published var measures: [Measure] = [] // Update each time the legislator data is updated
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/Measures?$filter=CurrentCommitteeCode%20eq%20%27SEE%27&$format=json") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }

            do {
                let initial = try JSONDecoder().decode(InitialODATA.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    self?.measures = initial.value
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct MeasureView: View {
    @StateObject var dataModel = MeasureData()
    @State var measuretoggles: [Bool] = [false]
    var index = 0
    var body: some View {
        List {
            ForEach(dataModel.measures, id: \.self) { measure in
                    HStack (alignment: .top){
                        // The images aren't provided in the api, so I created links to them myself using their websites,
                        // some of the geezers put whitespace in their URL's so I removed it
                        Image(systemName: "doc.plaintext.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width:50, height:50)
                        VStack (alignment: .leading) {
                            Text("Measure "+String(measure.MeasureNumber))
                                .bold()
                            Text(measure.RelatingTo)
                            if (measuretoggles[index] == true) {
                                Text(measure.CatchLine)
                                    .bold()
                                Text(measure.CurrentLocation)
                                Text(measure.MeasureSummary)
                                    .scaledToFit()
                                    .hidden()
                            }
                        }.padding(4)
                    }.padding(3)
                    .onTapGesture {
                        withAnimation {self.measuretoggles[index].toggle()}
                    }
            }
        }
        .navigationTitle("Measures")
        .onAppear {
            dataModel.fetch()
        }
    }
}

