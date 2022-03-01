//
//  Network.swift
//  show_image
//
//  Created by shogo harada on 01/03/2022.

import Foundation

class ServiceManager {
    static let share = ServiceManager()
    var url: String = "https://api.unsplash.com/photos?client_id=iQaYbNGUdDpQDrVWJpJGKHFTChxr22iAWWDN6z8Outs"
    func fetchImage() {
        guard let url = URL(string: url) else {
            return
        }
        if let data = try? Data(contentsOf: url) {
            print(data)
            // parse json
            let decoder = JSONDecoder()
            if let results = try? decoder.decode([Photo].self, from: data) {
                print(results.count)
            } else {
                print("error decoder")
            }
        }
    }
}
