//
//  LocalStorageService.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/30/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import UIKit

class LocalStorageService {
    
    static let shared = LocalStorageService()
    
    private var imageDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first//?.appendingPathComponent("images")
    }
    
    /// save image from url in local directory
    func saveImage(fromUrl path: String?, completion: @escaping ((String?) -> Void)) {
        guard
            let directory = imageDirectory,
            let imagePath = path,
            let url = URL(string: imagePath) else {
                completion(nil)
                return
        }
        let uid = UUID().uuidString
        let fileName = "\(uid).jpg"
        let fileUrl = directory.appendingPathComponent(fileName)
        
        let mainQueue = DispatchQueue.main
        
        NetworkService.shared.downloadImage(url: url) { image in
            guard let imageData = image?.jpegData(compressionQuality: 1.0) else {
                completion(nil)
                return
            }
                do {
                    try imageData.write(to: fileUrl)
                    mainQueue.async {
                        completion(fileName)
                    }
                } catch let error as NSError {
                    print("error \(error.userInfo)")
                    mainQueue.async {
                        completion(nil)
                    }
                }
            
        }
    }
    
    /// get image from local directory
    func image(fromFile fileName: String?, completion: @escaping ((UIImage?) -> Void)) {
        guard let imageFileName = fileName,
              let imageUrl = imageDirectory?.appendingPathComponent(imageFileName) else {
                completion(nil)
                return
        }
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        let mainQueue = DispatchQueue.main
        queue.async {
            do {
                let imageData = try Data(contentsOf: imageUrl)
                let image = UIImage(data: imageData)
                mainQueue.async {
                    completion(image)
                }
            } catch {
                mainQueue.async {
                    completion(nil)
                }
            }
        }
    }
    
    /// remove image from local directory
    func removeImage(at fileName: String?) {
        guard let imageFileName = fileName,
            let imageUrl = imageDirectory?.appendingPathComponent(imageFileName) else {
                return
        }
        try? FileManager.default.removeItem(at: imageUrl)
    }
}
