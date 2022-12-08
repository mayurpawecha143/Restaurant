//
//  ImageDownloadManager.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/6/22.
//

import Foundation
import UIKit

protocol ImageDownloader {
    func downloadImage(with imageUrlString: String,
                       id: String,
                       completionHandler: @escaping (Result<UIImage, ImageDownloadError>) -> Void)
}

class ImageDownloadManager: ImageDownloader {
    static let shared = ImageDownloadManager()
    
    private var cachedImages: [String: UIImage]
    private var imagesDownloadTasks: [String: URLSessionDataTask]
    
    private let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    private let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)
    
    private init() {
        cachedImages = [:]
        imagesDownloadTasks = [:]
    }
    
    func downloadImage(with imageUrlString: String,
                       id: String,
                       completionHandler: @escaping (Result<UIImage, ImageDownloadError>) -> Void) {
        
        if let image = getCachedImageFrom(id: id) {
            completionHandler(.success(image))
        } else {
            guard let url = URL(string: imageUrlString) else {
                completionHandler(.failure(.urlError))
                return
            }
            if let _ = getDataTaskFrom(id: id) {
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let _ = error {
                    completionHandler(.failure(.downloadError))
                }
                if let data = data, let image = UIImage(data: data) {
                    self.serialQueueForImages.sync(flags: .barrier) {
                        self.cachedImages[id] = image
                    }
                    _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
                        self.imagesDownloadTasks.removeValue(forKey: id)
                    }
                    completionHandler(.success(image))
                } else {
                    completionHandler(.failure(.conversionError))
                }
            }
            self.serialQueueForDataTasks.sync(flags: .barrier) {
                imagesDownloadTasks[imageUrlString] = task
            }
            task.resume()
        }
    }
    
    private func getCachedImageFrom(id: String) -> UIImage? {
        serialQueueForImages.sync {
            return cachedImages[id]
        }
    }
    
    private func getDataTaskFrom(id: String) -> URLSessionTask? {
        serialQueueForDataTasks.sync {
            return imagesDownloadTasks[id]
        }
    }
}
