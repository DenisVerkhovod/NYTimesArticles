//
//  BaseViewController.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/27/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var feed: Feed!
    var type: FeedType {
        return .emailed
    }
    
    var offset: Int {
        return feed.articles?.count ?? 0
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureTableView()
        updateFeed()
    }
    
    private func configure() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = type.titleDescription
        feed = Feed.create(in: CoreData.stack.backgroundContext)
        print("total article: \(feed.totalArticles)")
    }
    
    private func configureTableView() {
        let cellIdentifier = String(describing: ArticleTableViewCell.self)
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.prefetchDataSource = self
    }
    
    private func updateFeed() {
        FeedService.shared.update(feed: feed, by: offset, type: type) { [weak self] feed, error in
            if let error = error {
                if error == .requestsLimit {
                    self?.presentAlert(with: error.description)
                }
                return
            }
            self?.tableView.reloadData()
        }
    }
    
    private func isLoadingCell(at indexPath: IndexPath) -> Bool {
        return indexPath.row >= feed.articles?.count ?? 0
    }
    
    private func presentAlert(with text: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension BaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.totalArticlesIntValue ?? 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell
        if isLoadingCell(at: indexPath) {
            cell.configure(with: nil)
        } else {
            let article = feed.articles?.object(at: indexPath.row) as? Article
            cell.configure(with: article)
        }
        
        return cell
    }
}

extension BaseViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            updateFeed()
        }
    }
}

extension BaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("IndexPath: \(indexPath.row)")
        let article = feed.articles?.object(at: indexPath.row) as! Article
        article.addToFavorite()
//        let id = article.objectID
//        let favoriteArticle = CoreData.stack.mainContext.object(with: id)
        print("ADDED!")
//        CoreData.stack.saveContext()
    }
}
