//
//  Article + extension.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/31/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension Article {
    
    var emailedIntValue: Int? {
        let value = Int(emailed)
        return value >= 0 ? value : nil
    }
    
    var sharedIntValue: Int? {
        let value = Int(shared)
        return value >= 0 ? value : nil
    }
    
    var viewedIntValue: Int? {
        let value =  Int(viewed)
        return value >= 0 ? value : nil
    }
    
    class func create(in context: NSManagedObjectContext, from json: JSON) -> Article {
        let article = Article(context: context)
        article.title = json["title"].stringValue
        article.published = json["published_date"].stringValue
        article.link = json["url"].stringValue
        if let emailed = json["email_count"].int16 {
            article.emailed = emailed
        }
        if let shared = json["share_count"].int16 {
            article.shared = shared
        }
        if let viewed = json["views"].int16 {
            article.viewed = viewed
        }
        article.thumbImageLink = json["media"].array?.first?["media-metadata"].array?[1]["url"].string ?? ""
        
        return article
    }
    
    @discardableResult
    private func makeCopy(in context: NSManagedObjectContext) -> Article {
        let newArticle = Article(context: context)
        newArticle.title = self.title
        newArticle.link = self.link
        newArticle.published = self.published
        newArticle.emailed = self.emailed
        newArticle.shared = self.shared
        newArticle.viewed = self.viewed
        LocalStorageService.shared.saveImage(fromUrl: self.thumbImageLink) { path in
            newArticle.thumbImageLocalPath = path
            self.saveChanges()
        }
        
        return newArticle
    }
    
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        
        LocalStorageService.shared.removeImage(at: thumbImageLocalPath)
    }
    
    func addToFavorite() {
        let mainContext = stack.mainContext
        self.makeCopy(in: mainContext)
        saveChanges()
    }
    
    func saveChanges() {
        stack.saveContext()
    }
}
