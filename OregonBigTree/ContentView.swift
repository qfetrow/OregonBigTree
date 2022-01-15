//
//  ContentView.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 1/13/22.
//

import SwiftUI

extension String {
    // Just a function for trimming whitespace
    func removeWhitespace() -> String {
        return components(separatedBy: .whitespaces).joined()
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


// OData is strange because it returns a .json object with {[metadata]:[link], [value][REQUESTED INFORMATION]}
// So this parses the returned object to only get the needed information

struct Initial: Codable {
    let value: [Legislator]
}

// The names are dependent on OData values so do not change them
struct Legislator: Hashable, Codable {
    let FirstName: String
    let LastName: String
    let Party: String
    let WebSiteUrl: String
    let DistrictNumber: String
}

class ViewModel: ObservableObject {
    // This reads all legislator data from the api into legislators
    
    @Published var legislators: [Legislator] = [] // Update each time the legislator data is updated
    
    func fetch() {
        // This URL is super complicated, but it's calling '$filter' to request only legislators that are serving
        // in the current session
        guard let url = URL(string: "https://api.oregonlegislature.gov/odata/odataservice.svc/Legislators?$filter=SessionKey%20eq%20%272021S2%27%20&$format=json") else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return // no data
            }

            do {
                let initial = try JSONDecoder().decode(Initial.self, from: data) // fills 'legislators' with data
                DispatchQueue.main.async {
                    self?.legislators = initial.value
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List{
                ForEach(viewModel.legislators, id: \.self) { legislator in
                    HStack() {
                        // The images aren't provided in the api, so I created links to them myself using their websites and
                        // a common formatting, some of the crusty geezers put whitespace in their URL's so I removed it
                        URLImage(urlString: legislator.WebSiteUrl.removeWhitespace()+"/PublishingImages/member_photo.jpg")
                        VStack (alignment: .leading){
                            Text(legislator.FirstName + " " + legislator.LastName)
                                .bold()
                            Text(legislator.Party)
                            Text("District "+legislator.DistrictNumber)
                        }.padding(4)
                    }
                    .padding(3)
                }
            }
            .navigationTitle("All Legislators")
            .onAppear {
                viewModel.fetch()
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
