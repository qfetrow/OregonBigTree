
//
//  RepsByAddress.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/21/22.
//

import Foundation


import SwiftUI

extension String {
    // Just a function for trimming whitespace
    func removeWhitespace() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    func removeTabs() -> String {
        return self.filter{ !"\t".contains($0) }
    }
    // Used to replace whitespace with "%20" for APi interaction
    func withReplacedCharacters(_ oldChar: String, by newChar: String) -> String {
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
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
    var fullAddress: String = ""
    
    // These variables decide what is being displayed
    @State var addressRecieved: Bool = false
    @State var showingAddressForm: Bool = false
    @StateObject var dataModel = DataModel()
    
    var body: some View {
        NavigationView {
            if (addressRecieved == false) { // Need to collect address
                if (showingAddressForm == false) { //
                    VStack {
                        Text("Enter your Address to display your local Representatives")
                        Button("Enter Address") {
                            showingAddressForm = true
                        }
                    }
                } else {
                    // This is the Email Form for the user
                    NavigationView {
                        Form {
                            TextField("Street Address", text: $street)
                            TextField("City", text: $city)
                            TextField("Zip Code", text: $zip)
                            Button("Confirm") {
                                self.street = self.street
                                self.fulladdress = self.street.withReplacedCharacters(" ", by: "%20")+"%20"+self.city+"%20"+"OR%20"+self.zip
                                print("Address! -------------------------- "+self.fulladdress)
                                dataModel.address = self.fulladdress
                                addressRecieved = true
                            }
                        }
                        .navigationBarTitle("Address")
                    }
                }
            } else {
                    // Shows the representatives
                    List{
                        ForEach(dataModel.offices, id: \.self) { office in
                                if (office.name == "OR State Senator" || office.name == "OR State Representative") { // Only show senator and representative
                                    let legislator = dataModel.representatives[office.officialIndices[0]]
                                    HStack (alignment: .top){
                                        // The images aren't provided in the api, so I created links to them myself using their websites,
                                        // some of the geezers put whitespace in their URL's so I removed it
                                        URLImage(urlString: legislator.urls[0].removeWhitespace()+"/PublishingImages/member_photo.jpg")
                                        VStack (alignment: .leading) {
                                            Text(legislator.name)
                                                .bold()
                                            Text(legislator.party)
                                            if let unwrapped_emails = legislator.emails{
                                                Text(unwrapped_emails[0])
                                            }
                                        }.padding(4)
                                    }.padding(3)
                            }
                        }
                    }
                    .navigationTitle("Your Representatives")
                    .onAppear {
                        dataModel.fetch()
                    }
                }
            }
        }
}
