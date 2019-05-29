//
//  Feed.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/27/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import SwiftyJSON

class Feed {
    var articles: [Article] = []
    var totalArticles: Int
    
    init() {
        totalArticles = 0
    }
    
    func append(from json: JSON) {
        json.arrayValue.forEach({
            let article = Article(with: $0)
            self.articles.append(article)
        })
    }
    
//    enum CodingKeys: String, CodingKey {
//        case articles = "results"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.articles = try container.decode([Article].self, forKey: .articles)
//    }
    
}
