//
//  NetworkService.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/27/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkService {
    
    static let shared = NetworkService()
    
    func request(url: URLConvertible, parameters: Parameters, completion: @escaping ((Result<JSON>) -> Void)) {

        let parameters = ([Constants.apiKey: Constants.key] as Parameters).merging(parameters) { first, _ in first }
        
        Alamofire.request(url, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let json = response.result.value else { return }
                    completion(.success(JSON(json)))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    //    func request(url: URLConvertible) {
    //        Alamofire.request(url)
    //            .validate()
    //            .response { response in
    //                guard let data = response.data else { return }
    //                print(data)
    //
    ////                let feed = try? JSONDecoder().decode(Feed.self, from: data)
    ////                print(feed)
    //                let json = try? JSONSerialization.jsonObject(with: data, options: [])
    //                guard let json1 = json as? [String: Any] else { return }
    //                print(json1)
    //        }
    //    }
}
