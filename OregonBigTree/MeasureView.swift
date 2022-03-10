//
//  MeasureView.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/27/22.
//

import MessageUI
import SwiftUI
import Foundation

class MeasureGetter: ObservableObject {
    // This reads all measure data from the api into measure objects
    @Published var dataRead: Bool = false
    @Published var measureprefix: String
    @Published var measurenumber: Int
    @Published var measures: [Measure] = []
    @Published var measure: Measure? = nil
    
    init(mprefix: String, measureNumber: Int) {
        self.measureprefix = mprefix
        self.measurenumber = measureNumber
    }
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/Measures?$format=json&$filter=MeasurePrefix%20eq%20%27\(measureprefix)%27%20and%20MeasureNumber%20eq%20\(measurenumber)&$orderby=CreatedDate%20desc&$top=1") else {
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
                    self?.dataRead = true
                    self?.measures = [initial.value[0]]
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

class MeasureDocumentData: ObservableObject {
    // This reads all measure data from the api into measure objects
    @Published var sessionkey: String
    @Published var measurenumber: Int
    @Published var measureprefix: String
    @Published var measureDocs: [MeasureDocument] = [] // Update each time the legislator data is updated
    
    init(sessionKey: String, measureNumber: Int, measurePrefix: String) {
        self.sessionkey = sessionKey
        self.measurenumber = measureNumber
        self.measureprefix = measurePrefix
    }
    
    func fetch(){
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/MeasureDocuments?$format=json&$filter=SessionKey%20eq%20%27\(sessionkey)%27%20and%20MeasureNumber%20eq%20\(measurenumber)%20and%20MeasurePrefix%20eq%20%27\(measureprefix)%27&$orderby=ModifiedDate%20desc") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }
            do {
                let initial = try JSONDecoder().decode(InitialMeasureDoc.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    self?.measureDocs = initial.value
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

class MeasureData: ObservableObject {
    // This reads all measure data from the api into measure objects
    private let committeecode: String
    @Published var measures: [Measure] = [] // Update each time the legislator data is updated
    @Published var dataread: Bool = false
    
    init(commitcode: String) {
        self.committeecode = commitcode
    }
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/Measures?$filter=CurrentCommitteeCode%20eq%20%27\(committeecode)%27&$orderby=CreatedDate%20desc&$format=json") else {
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
        self.dataread = true
        task.resume()
    }
}
struct historyLabel: View {
    var body: some View {
        HStack {
            Image(systemName: "clock")
            Text("Measure Actions")
        }
        .padding(3)
    }
}
struct scrollableMeasureSum: View {
    var measure: Measure
    var body: some View {
        VStack {
            List {
                VStack (alignment: .leading) {
                    Text("Fiscal Impact: ")
                        .bold()
                    if let a = measure.FiscalImpact {
                        Text(a)
                    } else {
                        Text("Unknown")
                    }
                }
                VStack (alignment: .leading) {
                    Text("Fiscal Analyst: ")
                        .bold()
                    if let a = measure.FiscalAnalyst {
                        Text(a)
                    } else {
                        Text("None")
                    }
                }
                VStack (alignment: .leading) {
                    Text("Revenue Impact: ")
                        .bold()
                    if let a = measure.RevenueImpact {
                        Text(a)
                    } else {
                        Text("Unknown")
                    }
                }
                VStack (alignment: .leading) {
                    Text("Revenue Economist: ")
                        .bold()
                    if let a = measure.RevenueEconomist {
                        Text(a)
                    } else {
                        Text("None")
                    }
                }
                VStack (alignment: .leading) {
                    Text("Current Location: ")
                        .bold()
                    Text(measure.CurrentLocation)
                }
                VStack (alignment: .leading) {
                    Text("Date Created: ")
                        .bold()
                    Text(measure.CreatedDate.convertDate())
                }
                VStack (alignment: .leading) {
                    Text("Last Modified: ")
                        .bold()
                    Text(measure.ModifiedDate.convertDate())
                }
            }.listStyle(PlainListStyle())
        }
    }
}

struct ExpandedMeasureView: View {
    @State var measure: Measure
    @State var timelineView: Bool = false
    @State var measureSumView: Bool = false
    @StateObject var docData: MeasureDocumentData
    init(measure: Measure) {
        _docData = StateObject(wrappedValue: MeasureDocumentData(sessionKey: measure.SessionKey, measureNumber: measure.MeasureNumber, measurePrefix: measure.MeasurePrefix))
        self.measure = measure
    }
    var body: some View {
        VStack (alignment: .leading) {
            ScrollView {
                // Really janky reformatting with this haha
                Text(measure.MeasureSummary.htmlnotationConvert().removeTabs().withReplacedCharacters("\n", by: "\n\n"))
                    .padding(10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .padding(10)
            .frame(maxHeight: 400)
            List {
                NavigationLink {
                    scrollableMeasureSum(measure: measure)
                } label: {
                    HStack {
                        Image(systemName: "text.redaction")
                        Text("Measure Details")
                    }
                }
                NavigationLink {
                    MeasureHistoryView(sessionKey: measure.SessionKey, measureNumber: measure.MeasureNumber)
                } label: {
                    historyLabel()
                }
                .listStyle(SidebarListStyle())
                if (docData.measureDocs != []) {
                    if let docurl = URL(string: docData.measureDocs[0].DocumentUrl) {
                        HStack {
                            Image(systemName: "doc")
                            Link("View Document", destination: docurl)
                        }
                    }
                }
                NavigationLink {
                    MailSetUp(legid: "Representative \(GlobalReps[0].name)", recipiented: GlobalReps[0].email, prefix: measure.MeasurePrefix, measurenumber: measure.MeasureNumber, relatingto: measure.RelatingTo)
                } label: {
                    Text("Email House Representative")
                }
                NavigationLink {
                    MailSetUp(legid: "Senator \(GlobalReps[1].name)", recipiented: GlobalReps[1].email, prefix: measure.MeasurePrefix, measurenumber: measure.MeasureNumber, relatingto: measure.RelatingTo)
                } label: {
                    Text("Email Senator")
                }
                
            }.listStyle(PlainListStyle())
        }
        .onAppear() {
            docData.fetch()
        }
        .navigationBarTitle(Text("\(measure.MeasurePrefix) \(measure.MeasureNumber)"), displayMode: .inline)
    }
}

struct SingleMeasureView: View {
    @State private var presentmail = true
    @State var measure: Measure
    var body: some View {
        HStack (alignment: .center){
            if (measure.MeasurePrefix.contains("HB")) {
                Image(systemName: "doc.plaintext.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:60, height:60)
                    .foregroundColor(blue)
            } else if (measure.MeasurePrefix.contains("SB")){
                Image(systemName: "doc.plaintext.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:60, height:60)
                    .foregroundColor(green)
            } else {
                Image(systemName: "doc.plaintext.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:60, height:60)
                    .foregroundColor(red)
            }
            VStack (alignment: .leading) {
                Text(measure.MeasurePrefix+" "+String(measure.MeasureNumber))
                    .bold()
                Text(measure.RelatingTo)
                Text(measure.PrefixMeaning)
                    .foregroundColor(.gray)
            }.padding(.leading, 4)
        }.padding(3)
    }
}

struct SingleFromPrefixNumber: View {
    @StateObject private var dataModel: MeasureGetter
    init(mnumber: Int, mprefix: String) {
        _dataModel = StateObject(wrappedValue: MeasureGetter(mprefix: mprefix, measureNumber: mnumber))
    }
    var body: some View {
        VStack {
            if (dataModel.measures != []) {
                let measure = dataModel.measures[0]
                VStack {
                    NavigationLink {
                        ExpandedMeasureView(measure: measure)
                    } label: {
                        SingleMeasureView(measure: measure)
                    }
                }
            }
            
        }
        .onAppear {
            if (dataModel.dataRead) {

            } else {
                dataModel.fetch()
            }
        }
    }
    
}

struct MeasureListView: View {
    @StateObject private var dataModel: MeasureData
    var committeestring: String
    init(committeeCode: String, committeeString: String) {
        _dataModel = StateObject(wrappedValue: MeasureData(commitcode: committeeCode))
        self.committeestring = committeeString
    }
    @State var index: Int = 0
    var body: some View {
        List {
            ForEach(dataModel.measures, id: \.self) { measure in
                NavigationLink {
                    ExpandedMeasureView(measure: measure)
                } label: {
                    SingleMeasureView(measure: measure)
                }
            }
        }
        .navigationBarTitle(Text(self.committeestring), displayMode: .inline)
        .onAppear {
            dataModel.fetch()
        }
    }
}

