//
//  Article.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/27/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Article {
    let title: String
    let published: String
    let link: String
    let thumbImage: String
    let emailed: Int?
    let shared: Int?
    let viewed: Int?
    
    init(with json: JSON) {
        self.title = json["title"].string ?? ""
        self.published = json["published_date"].string ?? ""
        self.link = json["url"].string ?? ""
        self.emailed = json["email_count"].int
        self.shared = json["share_count"].int
        self.viewed = json["views"].int
        self.thumbImage = json["media"].array?.first?["media-metadata"].array?[1]["url"].string ?? ""
        
    }
    
//    var thumbImageUrl: URL? {
//        return URL(string: thumbImage)
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case title
//        case published = "published_date"
//        case link = "url"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.title = try container.decode(String.self, forKey: .title)
//        self.published = try container.decode(String.self, forKey: .published)
//        self.link = try container.decode(String.self, forKey: .link)
////        self.updated = try resultContainer.decode(String.self, forKey: .updated)
////        self.link = try resultContainer.decode(String.self, forKey: .link)
//    }
    
}
