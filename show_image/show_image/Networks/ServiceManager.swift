//
//  Network.swift
//  show_image
//
//  Created by shogo harada on 01/03/2022.

import Foundation

enum NetWorkError: Error {
    case BaseURL
    case CallAPI
    case Decode
}

class ServiceManager {
    static let share = ServiceManager()
    var url: String = "https://api.unsplash.com/photos?client_id=iQaYbNGUdDpQDrVWJpJGKHFTChxr22iAWWDN6z8Outs&per_page=100"
    func fetchImage(completion: @escaping (Result<[Photo], NetWorkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.BaseURL))
            return
        }
        if let data = try? Data(contentsOf: url) {
            // parse json
            let decoder = JSONDecoder()
            if let results = try? decoder.decode([Photo].self, from: data) {
                completion(.success(results))
                print(results.count)
            } else {
                completion(.failure(.Decode))
                print("error decoder")
            }
        } else {
            completion(.failure(.CallAPI))
        }
    }
}
