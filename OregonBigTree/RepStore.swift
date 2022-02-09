//
//  RepStore.swift
//  OregonBigTree
//
//  Created by Quinn Fetrow on 2/1/22.
//
import Foundation
import SwiftUI

class RepStore: ObservableObject {
    @Published var reps: [Representative] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("reps.data")
    }
    
    static func load(completion: @escaping (Result<[Representative], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let reps = try JSONDecoder().decode([Representative].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(reps))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(reps: [Representative], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(reps)
                let outfile = try fileURL()
                try data.write(to: outfile)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                } 
            }
        }
    }
}
