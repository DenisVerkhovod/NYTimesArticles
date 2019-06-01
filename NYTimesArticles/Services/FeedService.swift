//
//  FeedService.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/28/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import Alamofire

enum FeedError: Error {
    case download
    case requestsLimit
    
    var description: String {
        switch self {
        case .download:
            return "Unable to download feed"
            
        case .requestsLimit:
            return "Too many requests. Try again in a minute"
        }
    }
}

enum FeedType: String {
    case emailed
    case shared
    case viewed
    
    var description: String {
        return rawValue + "/30.json"
    }
    
    var titleDescription: String {
        switch self {
        case .emailed:
            return "Most Emailed"
        case .shared:
            return "Most Shared"
        case .viewed:
            return "Most Viewed"
        }
    }
}

final class FeedService {
    
    static let shared = FeedService()
    
    private var isInProgress = false
    func update(feed: Feed, by offset: Int, type: FeedType, completion: @escaping ((Feed?, FeedError?) -> Void)) {
        guard !isInProgress else { return }
        isInProgress = true
        let url = Constants.baseURL.appendingPathComponent(type.description)
        
        let parameters = [Constants.offset: offset]
        
        NetworkService.shared.request(url: url, parameters: parameters) { [weak self] result in
            switch result {
            case .success(let value):
                self?.isInProgress = false
                let total = value["num_results"].int ?? 0
                feed.totalArticles = Int16(total)
                print("total articles: \(total)")
                feed.append(contentOf: value["results"])
                DispatchQueue.main.async {
                    completion(feed, nil)
                }
            case .failure(let error):
                self?.isInProgress = false
                DispatchQueue.main.async {
                    if
                        let afError = error as? AFError,
                        afError.responseCode == 429 {
                        completion(nil, .requestsLimit)
                    } else {
                    completion(nil, .download)
                    }
                }
            }
        }
    }
}
