//
//  MeasureHistory.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 2/9/22.
//

import Foundation
import SwiftUI

class MeasureHistoryData: ObservableObject {
    // This reads all measure data from the api into measure objects
    @Published var dataRead: Bool = false
    @Published var sessionkey: String
    @Published var measurenumber: Int
    @Published var measureHists: [MeasureHistoryAction] = [] // Update each time the legislator data is updated
    @Published var measureScheds: [MeasureHistoryAction] = [] // Update each time the legislator data is updated
    
    init(sessionKey: String, measureNumber: Int) {
        self.sessionkey = sessionKey
        self.measurenumber = measureNumber
    }
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/MeasureHistoryActions?$format=json&$filter=SessionKey%20eq%20%27\(sessionkey)%27%20and%20MeasureNumber%20eq%20\(measurenumber)") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }

            do {
                let initial = try JSONDecoder().decode(InitialMeasureHistory.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    for event in initial.value {
                        if event.ActionText.lowercased().contains("scheduled") {
                            self?.measureScheds.insert(event, at: 0)
                        } else {
                            self?.measureHists.append(event)
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

struct MeasureHistoryView: View {
    @StateObject private var dataModel: MeasureHistoryData
    init(sessionKey: String, measureNumber: Int) {
        _dataModel = StateObject(wrappedValue: MeasureHistoryData(sessionKey: sessionKey, measureNumber: measureNumber))
    }

    var body: some View {
        List{
            Section(header: Text("Previous Actions")) {
                ForEach(dataModel.measureHists, id: \.self) { action in
                    HStack {
                        Image(systemName: timelineIconGenerator(for: action.ActionText))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)

                        VStack (alignment: .leading) {
                            Text(action.ActionDate.convertDate())
                                .bold()
                            Text(action.ActionText)
                        }.padding(4)
                    }
                }
            }
            Section(header: Text("Scheduled Actions")) {
                ForEach(dataModel.measureScheds, id: \.self) { action in
                    HStack {
                        Image(systemName: timelineIconGenerator(for: action.ActionText))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)

                        VStack (alignment: .leading) {
                            Text(action.ActionDate.convertDate())
                                .bold()
                            Text(action.ActionText)
                        }.padding(4)
                    }
                }

            }
        }
        .listStyle(.plain)
        .onAppear {
            if dataModel.dataRead == false {
                dataModel.fetch()
            }
        }
    }
}

func timelineIconGenerator(for identifierinit: String) -> String {
    let identifier = identifierinit.lowercased()
    switch identifier {
    case _ where identifier.contains("passed"):
        return "hand.thumbsup"
    case _ where identifier.contains("failed"):
        return "hand.thumbsdown"
    case _ where identifier.contains("referred"):
        if identifier.contains("first") || identifier.contains("introduction"){
            return "1.circle"
        }
        return "arrowshape.turn.up.left"
    case _ where identifier.contains("informational"):
        return "info.circle"
    case _ where identifier.contains("in committee"):
        return "square.and.arrow.down"
    case _ where identifier.contains("second"):
           return "2.circle"
    case _ where identifier.contains("signed"):
        return "signature"
    case _ where identifier.contains("public"):
        return "figure.wave.circle"
    case _ where identifier.contains("work"):
        return "hammer.circle"
    case _ where identifier.contains("recommendation"):
        return "cross"
    default: return "circle"
    }
}
