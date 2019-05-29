//
//  FeedService.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/28/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation

enum FeedError: Error {
    case download
    
    var description: String {
        switch self {
        case .download:
            return "Unable to download feed"
        }
    }
}

enum FeedType: String {
    case emailed
    case shared
    case viewed
    
    var description: String {
            return rawValue + "/7.json"
    }
}

class FeedService {
    
    static let shared = FeedService()
    
    var isInProgress = false
    func update(feed: Feed, by offset: Int, type: FeedType, completion: @escaping ((Feed?, Error?) -> Void)) {
        guard !isInProgress else { return }
        isInProgress = true
        let url = Constants.baseURL.appendingPathComponent(type.description)
        
        let parameters = [Constants.offset: offset]
        
        NetworkService.shared.request(url: url, parameters: parameters) { [weak self] result in
            switch result {
            case .success(let value):
                self?.isInProgress = false
                let total = value["num_results"].int ?? 0
                feed.totalArticles = total
                feed.append(from: value["results"])
                DispatchQueue.main.async {
                    completion(feed, nil)
                }
            case .failure(let error):
                self?.isInProgress = false
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}
