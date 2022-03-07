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
        operation.maxConcurrentOperationCount = 3
        operation.name = "download operation"
        return operation
    }()
    
    lazy var filtrationsInProcess: [IndexPath:Operation] = [:]
    lazy var filtrationOperation: OperationQueue = {
        var operation = OperationQueue()
        operation.maxConcurrentOperationCount = 3
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
        guard let imageData = try? Data(contentsOf: URL(string: photo.photo.urls.thumb)!) else { return }
        
        if isCancelled {
          return
        }
        
        if !imageData.isEmpty {
            print("=== download image sucess")
            photo.state = .downloaded
            photo.image = UIImage(data: imageData)
        } else {
            print("=== download image fail")
            photo.state = .failed
            photo.image = UIImage(named: "Failed")
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
        guard self.photo.state == .downloaded else {
              return
            }
        if let image = photo.image,
           let filterImage = applySepiaFilter(image){
            photo.state = .filtered
            photo.image = filterImage
        }
    }
    func applySepiaFilter(_ image: UIImage) -> UIImage? {
        guard let data = image.pngData() else { return nil }
      let inputImage = CIImage(data: data)
          
      if isCancelled {
        return nil
      }
          
      let context = CIContext(options: nil)
          
      guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
      filter.setValue(inputImage, forKey: kCIInputImageKey)
      filter.setValue(0.8, forKey: "inputIntensity")
          
      if isCancelled {
        return nil
      }
          
      guard
        let outputImage = filter.outputImage,
        let outImage = context.createCGImage(outputImage, from: outputImage.extent)
      else {
        return nil
      }

      return UIImage(cgImage: outImage)
    }

}

class ImageOperationManager {
    let pendingOperation = PendingOperation()
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath, completion: @escaping ((IndexPath , PhotoRecord) -> Void)) {
        guard pendingOperation.downloadsInProcess[indexPath] == nil else {
            return
        }
        let downloader = ImageDownloader(photoRecord)
        downloader.completionBlock = {
            if downloader.isCancelled {
                  return
            }
            self.pendingOperation.downloadsInProcess.removeValue(forKey: indexPath)
            completion(indexPath, downloader.photo)
        }
        pendingOperation.downloadsInProcess[indexPath] = downloader
        pendingOperation.donwloadOperation.addOperation(downloader)
    }
    
    func startFiltration(for photoRecord: PhotoRecord, at indexPath: IndexPath, completion: @escaping ((IndexPath , PhotoRecord) -> Void)) {
        guard pendingOperation.filtrationsInProcess[indexPath] == nil else {
              return
          }
              
          let filterer = ImageFiltration(photoRecord)
        filterer.completionBlock = {
            if filterer.isCancelled {
              return
            }
            self.pendingOperation.filtrationsInProcess.removeValue(forKey: indexPath)
            completion(indexPath, filterer.photo)
          }
          
        pendingOperation.filtrationsInProcess[indexPath] = filterer
        pendingOperation.filtrationOperation.addOperation(filterer)
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
            downloadImageFromUrl(key: forkey) { imagepho in
                image = imagepho
            }
        }
        return image
    }
    
    func downloadImageFromUrl(key: String, completion: @escaping ((UIImage) -> Void)) {
        URLSession.shared.dataTask(with: URL(string: key)!) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data)
                self.cache.setObject(imageToCache!, forKey: key as NSString)
                if let image = imageToCache {
                    completion(image)
                }
            }
        }.resume()
    }
}
