//
//  ODATAClasses.swift
//  OregonBigTree
//
//  Classes used with ODATA API json decoding

import Foundation

// OData is strange because it returns a .json object with {[metadata]:[link], [value][REQUESTED INFORMATION]}
// So this parses the returned object to only get the needed information

struct InitialODATA: Codable {
    let value: [Legislator]
}

// The names are dependent on OData values so do not change them
struct Legislator: Hashable, Codable {
    let FirstName: String
    let LastName: String
    let CapitolAddress: String?
    let CapitolPhone: String?
    let Title: String
    let Chamber: String
    let Party: String
    let DistrictNumber: String
    let EmailAddress: String
    let WebSiteUrl: String
}

struct Measure: Hashable, Codable {
    let MeasureNumber: String?
    let CatchLine: String?
    let MeasureSummary: String?
}

