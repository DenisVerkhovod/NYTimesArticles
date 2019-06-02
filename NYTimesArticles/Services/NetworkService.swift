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

final class NetworkService {
    
    static let shared = NetworkService()
    
    func getJson(url: URLConvertible, parameters: Parameters, completion: @escaping ((Result<JSON>) -> Void)) {
        let parameters = ([Constants.apiKey: Constants.key] as Parameters).merging(parameters) { first, _ in first }
        
        Alamofire.request(url, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case let .success(json):
                    completion(.success(JSON(json)))
                case let .failure(error):
                    completion(.failure(error))
                }
        }
    }
    
    func getData(url: URLConvertible, completion: @escaping ((Result<Data>) -> Void)) {
        Alamofire.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case let .success(value):
                    completion(.success(value))
                case let .failure(error):
                    completion(.failure(error))
                }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        Alamofire.request(url).responseImage { response in
            let image: UIImage? = response.result.value
            completion(image)
        }
    }
}
