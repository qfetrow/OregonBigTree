//
//  GCivicClasses.swift
//  OregonBigTree
//
//  Classes used with Google Civic Info API json decoding

import Foundation

struct InitialGoogle: Codable {
    let offices: [Office]
    let officials: [Representative]
}

struct Office: Codable, Hashable{
    let name: String
    let officialIndices: [Int]
}

struct Representative: Codable, Hashable {
    let name: String
    let party: String
    let phones: [String]
    let urls: [String]
    let emails: [String]?
}
