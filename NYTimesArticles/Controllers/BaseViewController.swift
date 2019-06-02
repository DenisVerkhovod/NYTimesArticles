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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureTableView()
        updateFeed()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configure
    private func configure() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = type.titleDescription
        feed = Feed.create(in: CoreData.stack.backgroundContext)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteFromFavorites(_:)), name: .didRemoveFromFavorite, object: nil)
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
    
    // MARK: - Actions
    @objc func didDeleteFromFavorites(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String] else { return }
        let title = userInfo["title"]
        let articles = feed.articles?.compactMap({ $0 as? Article })
        let index = articles?.firstIndex(where: { $0.title == title })
        if let index = index {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Helpers
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

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDataSourcePrefetching
extension BaseViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            updateFeed()
        }
    }
}

// MARK: - UITableViewDelegate
extension BaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let article = feed.articles?.object(at: indexPath.row) as? Article else { return }
        article.addToFavorite()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addToFavoriteAction = UIContextualAction(style: .normal, title: "Add To Favorite") { [weak self] _, _, completion in
            guard let article = self?.feed.articles?.object(at: indexPath.row) as? Article else { return }
            article.addToFavorite()
            completion(true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [addToFavoriteAction])
    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        guard
//            let article = feed.articles?.object(at: indexPath.row) as? Article,
//            article.isInFavorite() else { return nil }
//        let removeFromFavoriteAction = UIContextualAction(style: .normal, title: "Remove from favorites") { _, _, completion in
//
//            let request: N =
//        }
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return []
    }
}
