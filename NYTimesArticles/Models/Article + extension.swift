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
    
    // MARK: - Properties
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
    
    // Factory method for create Article object
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
        let metadataArray = json["media"].array?.first?["media-metadata"].array
        article.thumbImageLink = metadataArray?[1]["url"].string ?? ""
        article.imageLink = metadataArray?[2]["url"].string ?? ""
        
        return article
    }
    
    /// create copy of Article in specified context
    @discardableResult
    private func makeCopy(in context: NSManagedObjectContext) -> Article {
        let newArticle = Article(context: context)
        newArticle.title = self.title
        newArticle.link = self.link
        newArticle.published = self.published
        newArticle.emailed = self.emailed
        newArticle.shared = self.shared
        newArticle.viewed = self.viewed
        newArticle.dateAdded = Date().timeIntervalSince1970
        Parser.shared.text(from: self.link, completion: { [weak self] text in
            newArticle.text = text
            self?.saveChanges()
        })
        LocalStorageService.shared.saveImage(fromUrl: thumbImageLink) { [weak self] path in
            newArticle.thumbImageLocalPath = path
            self?.saveChanges()
        }
        LocalStorageService.shared.saveImage(fromUrl: imageLink) { [weak self] path in
            newArticle.imageLocalPath = path
            self?.saveChanges()
        }
        
        return newArticle
    }
    
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        
        LocalStorageService.shared.removeImage(at: thumbImageLocalPath)
    }
    
    func addToFavorite() {
        guard !isInFavorite() else { return }
        let mainContext = stack.mainContext
        self.makeCopy(in: mainContext)
        saveChanges()
    }
    
    func isInFavorite() -> Bool {
        let request: NSFetchRequest<Article> = Article.fetchRequest()
        
        do {
            let results = try stack.mainContext.fetch(request)
            return results.map{ $0.title }.contains(self.title)
        } catch {
            print("Couldn't perform fetch request")
        }
        return false
    }
    
    func delete() {
        stack.mainContext.delete(self)
        stack.saveContext()
    }
    
    func saveChanges() {
        stack.saveContext()
    }
}

