
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
    @Published var invalidaddress: Bool = false
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let urld = urls.first {
            var fileURL = urld.appendingPathComponent("legislators")
            fileURL = fileURL.appendingPathExtension("json")
            let url = fileURL
            do {
                let data = try? Data(contentsOf: url)
                if data != nil {
                    let initial = try JSONDecoder().decode(InitialGoogle.self, from: data!) // fills 'legislators' with data
                    DispatchQueue.main.async {
                        self.representatives = initial.officials
                        self.offices = initial.offices
                    }
                } else {
                    self.fromGoogle()
                    return
                }
            } catch {
                print("URL Problem, getting from Google")
                self.fromGoogle()
                return
            }
        } else {
            print("URL not found")
            self.fromGoogle()
            return
        }
    }
            
    func fromGoogle() {
        guard let url = URL(string: "https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyCvxPNqliq6JpAqabGtZC2cWpTSzX69WW8&?level=administrativeArea1&roles=legislatorLowerBody&roles=legislatorUpperBody&address="+self.address) else {
                print("https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyCvxPNqliq6JpAqabGtZC2cWpTSzX69WW8&?level=administrativeArea1&roles=legislatorLowerBody&roles=legislatorUpperBody&address="+self.address)
                return
            }

            
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                self?.invalidaddress = true
                return
            }
            do {
                let fm = FileManager.default
                let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
                if let urld = urls.first {
                    var fileURL = urld.appendingPathComponent("legislators")
                    fileURL = fileURL.appendingPathExtension("json")
                    try data.write(to: fileURL, options: [])
                }
            }
            catch {
                self?.invalidaddress = true
                print(error)
            }
            do {
                let initial = try JSONDecoder().decode(InitialGoogle.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    self?.representatives = initial.officials
                    self?.offices = initial.offices
                }
            }
            catch {
                self?.invalidaddress = true
                self?.address = ""
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
                VStack (alignment: .leading){
                    Form {
                        Section( footer: Text("Enter your address to view your local legislators.  Your address will be shared with the Google Civic Information API to return your Representatives")) {
                            TextField("Street Address", text: $street)
                            TextField("City", text: $city)
                            TextField("Zip Code", text: $zip)
                            Button("Confirm") {
                                self.street = self.street
                                self.fullAddress = self.street.withReplacedCharacters(" ", by: "%20")+"%20"+self.city+"%20"+"OR%20"+self.zip
                                addressRecieved = true
                            }
                        }
                    }
                }
                .navigationBarTitle("Your Address", displayMode: .large)
            } else {
                if (dataModel.invalidaddress == false) {
                    VStack {
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
                        VStack {
                            Button("Change Address") {
                                do {
                                    let nullstring = " ".data(using: .ascii)
                                    let fm = FileManager.default
                                    let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
                                    if let urld = urls.first {
                                        var fileURL = urld.appendingPathComponent("legislators")
                                        fileURL = fileURL.appendingPathExtension("json")
                                        try nullstring?.write(to: fileURL, options: [])
                                    }
                                } catch {
                                    print("Bad news")
                                }
                                self.fullAddress = ""
                            }
                            .padding(15)
                            .buttonStyle( RoundedRectangleButtonStyle())
                        }
                    }
                    .navigationBarTitle("Your Representatives")
                    .onAppear {
                        dataModel.address = self.fullAddress
                        dataModel.fetch()
                    }
                }
                else {
                    VStack (alignment: .leading) {
                        Text("Oops...")
                            .bold()
                            .font(.largeTitle)
                            .padding()
                        Text("Looks Like the address you provided was invalid, please double check your information")
                            .padding()
                        Button("Re-enter Address") {
                            dataModel.invalidaddress = false
                            fullAddress = ""
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
                        .padding()
                        Spacer()
                        Spacer()
                    }
                }
            }
        }
    }
}
