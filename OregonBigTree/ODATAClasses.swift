//
//  ODATAClasses.swift
//  OregonBigTree
//
//  Classes used with ODATA API json decoding

import Foundation
import UIKit

// OData is strange because it returns a .json object with {[metadata]:[link], [value][REQUESTED INFORMATION]}
// So this parses the returned object to only get the needed information

struct InitialCommitteeItem: Codable {
    let value: [CommitteeAgendaItem]
}

struct InitialCommitteeMeeting: Codable {
    let value: [CommitteeMeeting]
}

struct InitialODATA: Codable {
    let value: [Measure]
}

struct InitialMeasureDoc: Codable {
    let value: [MeasureDocument]
}

struct InitialMeasureHistory: Codable {
    let value: [MeasureHistoryAction]
}

struct InitialCommittee: Codable {
    let value: [Committee]
}


struct InitialFloor: Codable {
    let value: [FloorSessionAgendaItem]
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

struct MeasureHistoryAction: Hashable, Codable {
    let SessionKey: String
    let MeasureNumber: Int
    let Chamber: String
    let ActionDate: String
    let ActionText: String
    let VoteText: String?
}

struct Measure: Hashable, Codable {
    let SessionKey: String
    let MeasurePrefix: String
    let MeasureNumber: Int
    let CatchLine: String
    let MeasureSummary: String
    let CurrentVersion: String?
    let RelatingTo: String
    let CurrentLocation: String
    let CurrentCommitteeCode: String?
    let FiscalImpact: String?
    let RevenueImpact: String?
    let FiscalAnalyst: String?
    let RevenueEconomist: String?
    let CreatedDate: String
    let ModifiedDate: String
    let PrefixMeaning: String
}

struct Committee: Hashable, Codable {
    let CommitteeCode: String
    let CommitteeName: String
    let HouseOfAction: String
    let CommitteeType: String
}

struct MeasureDocument: Hashable, Codable {
    let SessionKey: String
    let MeasureNumber: Int
    let DocumentUrl: String
}

struct FloorSessionAgendaItem: Hashable, Codable {
    let SessionKey: String
    let MeasurePrefix: String
    let MeasureNumber: Int
    let ScheduleDate: String
    let Chamber: String
    let OrderOfBusiness: String
    let CreatedDate: String
}

struct CommitteeMeeting: Hashable, Codable {
    let SessionKey: String
    let CommitteeCode: String
    let MeetingDate: String
    let MeetingStatusCode: String
    let Location: String
    let AgendaURL: String?
}

struct CommitteeAgendaItem: Hashable, Codable {
    let SessionKey: String
    let CommitteeCode: String?
    let MeasurePrefix: String?
    let MeasureNumber: Int?
    let MeetingDate: String
    let MeetingType: String?
    let Action: String?
    let Comments: String?
}
