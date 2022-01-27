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

struct SingleMeasureView: View {
    @State var measure: Measure
    @State var fullview = false
    var body: some View {
        HStack (alignment: .center){
            if (fullview == false) {
                Image(systemName: "doc.plaintext.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:60, height:60)
            }
            VStack (alignment: .leading) {
                if (fullview == false) {
                    Text("Measure "+String(measure.MeasureNumber))
                        .bold()
                    Text(measure.RelatingTo)
                }
                else if (fullview == true) {
                    Text("Measure "+String(measure.MeasureNumber))
                        .bold()
                        .padding(.bottom,1)
                    VStack(alignment: .center) {
                        Text("Measure Summary")
                            .bold()
                            .padding(0)
                            .font(.system(size:15))
                        ScrollView {
                            // Really janky reformatting with this haha
                            Text(measure.MeasureSummary.removeTabs().withReplacedCharacters("\n", by: "\n\n"))
                                .padding(10)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .frame(minHeight:100, maxHeight:350)
                    }
                }
                Text(measure.PrefixMeaning)
                    .foregroundColor(.gray)
            }.padding(.leading, 4)
        }.padding(3)
        .onTapGesture {
            withAnimation {fullview.toggle()}
        }
    }
}

struct MeasureListView: View {
    @StateObject var dataModel = MeasureData()
    @State var isViewingMeasure: Bool = false
    @State var measuretoggles: [Bool] = [false]
    @State var index: Int = 0
    var body: some View {
        List {
            ForEach(dataModel.measures, id: \.self) { measure in
                SingleMeasureView(measure: measure)
            }
        }
        .navigationTitle("Measures")
        .onAppear {
            dataModel.fetch()
        }
    }
}

