//
//  OperationPhoto.swift
//  show_image
//
//  Created by shogo harada on 03/03/2022.
//

import Foundation
import UIKit

class PendingOperation {
    lazy var downloadsInProcess: [IndexPath: Operation] = [:]
    lazy var donwloadOperation: OperationQueue = {
        var operation = OperationQueue()
        operation.maxConcurrentOperationCount = 1
        operation.name = "download operation"
        return operation
    }()
    
    lazy var filtrationsInProcess: [IndexPath:Operation] = [:]
    lazy var filtrationOperation: OperationQueue = {
        var operation = OperationQueue()
        operation.maxConcurrentOperationCount = 1
        operation.name = "filtration operation"
        return operation
    }()
}

class ImageDownloader: Operation {
    var photo: PhotoRecord
    init(_ photo: PhotoRecord) {
        self.photo = photo
    }
    override func main() {
        if isCancelled {
            return
        }
        if let image = CacheImage.shared.imageCache(forkey: photo.photo.urls.thumb) {
            photo.state = .downloaded
            photo.image = image
        } else {
            photo.state = .failed
            photo.image = UIImage(systemName: "questionmark")
        }
    }
}

class ImageFiltration: Operation {
    var photo: PhotoRecord
    init(_ photo: PhotoRecord) {
        self.photo = photo
    }
    override func main() {
        if isCancelled {
            return
        }
        if let image = CacheImage.shared.imageCache(forkey: photo.photo.urls.thumb) {
            photo.state = .filtered
            photo.image = image
        }
    }

}

class ImageOperationManager {
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        
    }
}

class CacheImage {
    static let shared = CacheImage()
    var cache = NSCache<NSString, AnyObject>()
    func imageCache(forkey: String) -> UIImage? {
        var image: UIImage?
        if let imageCache = cache.object(forKey: forkey as NSString) as? UIImage {
            image = imageCache
        } else {
            URLSession.shared.dataTask(with: URL(string: forkey)!) { data, _, error in
                guard let data = data, error == nil else { return }
                let imageToCache = UIImage(data: data)
                self.cache.setObject(imageToCache!, forKey: forkey as NSString)
                image = imageToCache
            }.resume()
        }
        return image ?? nil
    }
}
