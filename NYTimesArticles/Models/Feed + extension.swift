//
//  Feed + extension.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/31/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension Feed {
    
    var totalArticlesIntValue: Int? {
        let value = Int(totalArticles)
        return value >= 0 ? value : nil
    }
    
    class func create(in context: NSManagedObjectContext) -> Feed {
        let feed = Feed(context: context)
        feed.articles = NSOrderedSet()
        return feed
    }
    
    func append(contentOf json: JSON) {
        var newArticles: [Article] = []
        json.arrayValue.forEach({
            let article = Article.create(in: self.managedObjectContext ?? CoreData.stack.backgroundContext,
                                         from: $0)
            newArticles.append(article)
        })
        guard let articles = self.articles?.mutableCopy() as? NSMutableOrderedSet else { return }
        articles.addObjects(from: newArticles)
        self.articles = articles
    }
}
