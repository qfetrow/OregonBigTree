
//
//  RepsByAddress.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/21/22.
//

import Foundation
import SwiftUI

var emptyRep = RepData(name: "", party: "", email: "", office: "")
var GlobalReps: [RepData] = [emptyRep, emptyRep]

struct RepView: View {
    let legislator: Representative
    let position: String
    
    var body: some View {
        HStack (alignment: .top){
            // The images aren't provided in the api, so I created links to them myself using their websites,
            // some of the geezers put whitespace in their URL's so I removed it
            URLImage(urlString: legislator.urls[0].removeWhitespace()+"/PublishingImages/member_photo.jpg")
            VStack (alignment: .leading) {
                Text(legislator.name)
                    .bold()
                Text(position)
                Text(legislator.party)
                if let unwrapped_emails = legislator.emails{
                    ForEach(unwrapped_emails, id: \.self) { emailad in
                        Text(emailad)
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                    }
                }
                if let unwrapped_phones = legislator.phones{
                    ForEach(unwrapped_phones, id: \.self) { phone in
                        Text(phone)
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .font(.subheadline)
                    }
                }
            }
            .padding(8)
        }
    }
}

struct URLImage: View {
    // Class to display representative photo
    let urlString: String
    
    @State var data: Data? // If data is updated, update display
    
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            // Valid URL
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 130)
                .background(Color.gray)
        } else {
            // No data to display
            Image("")
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 130)
                .background(Color.gray)
                .onAppear {
                    // Try to collect data
                    fetchData()
                }
        }
    }
    private func fetchData() {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data,
            _, _ in
            self.data = data
        }
        task.resume()
    }
}




class DataModel: ObservableObject {
    // This reads all legislator data from the api into legislators
    @Published var address: String = ""
    @Published var representatives: [Representative] = [] // Update each time the legislator data is updated
    @Published var offices: [Office] = []
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyCvxPNqliq6JpAqabGtZC2cWpTSzX69WW8&?level=administrativeArea1&roles=legislatorLowerBody&roles=legislatorUpperBody&address="+self.address) else {
                print("https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyCvxPNqliq6JpAqabGtZC2cWpTSzX69WW8&?level=administrativeArea1&roles=legislatorLowerBody&roles=legislatorUpperBody&address="+self.address)
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }

            do {
                let initial = try JSONDecoder().decode(InitialGoogle.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    self?.representatives = initial.officials
                    self?.offices = initial.offices
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct RepsByAddressView: View {
    
    // These variables are used to build the address
    @State var fulladdress: String = ""
    @State var street: String = ""
    @State var city: String = ""
    @State var zip: String = ""
    @AppStorage("fulladdress") var fullAddress: String = ""
    
    // These variables decide what is being displayed
    @State var loadedReps: [Representative] = []
    @State var repsLoaded: Bool = false
    @State var addressRecieved: Bool = false
    @State var showingAddressForm: Bool = false
    @StateObject var dataModel = DataModel()
    
    @State var repcounter = 0
    
    var body: some View {
        NavigationView {
            if (fullAddress == "") { // Need to collect address
                    // This is the address Form for the user
                NavigationView {
                    Form {
                        TextField("Street Address", text: $street)
                        TextField("City", text: $city)
                        TextField("Zip Code", text: $zip)
                        Button("Confirm") {
                            self.street = self.street
                            self.fullAddress = self.street.withReplacedCharacters(" ", by: "%20")+"%20"+self.city+"%20"+"OR%20"+self.zip
                            print("Address! -------------------------- "+self.fulladdress)
                            addressRecieved = true
                        }
                    }
                    .navigationBarTitle("Your Address", displayMode: .inline)
                }
            } else {
                    // Shows the representatives
                    List{
                        ForEach(dataModel.offices, id: \.self) { office in
                                if (office.name == "OR State Senator" || office.name == "OR State Representative") { // Only show senator and representative
                                    let position = office.name
                                    let legislator = dataModel.representatives[office.officialIndices[0]]
                                    RepView(legislator: legislator, position: position)
                                        .onAppear {
                                            GlobalReps[repcounter] = RepData(name: legislator.name, party: legislator.party, email: legislator.emails?[0] ?? "", office: "")
                                            repcounter = (repcounter + 1)%2
                                        }
                                }
                            }
                        }
                    .listStyle(PlainListStyle())
                    .navigationBarTitle("Your Representatives", displayMode: .inline)
                    .onAppear {
                        dataModel.address = self.fullAddress
                        dataModel.fetch()
                    }
                    Button("Change Address") {
                        self.fullAddress = ""
                    }
                }
            }
        }
}
