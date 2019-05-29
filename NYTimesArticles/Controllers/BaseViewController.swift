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
    var offset: Int {
        return feed.articles.count
    }

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        feed = Feed()
        configureTableView()
        updateFeed()
        
    }
    
    private func configureTableView() {
        let cellIdentifier = String(describing: ArticleTableViewCell.self)
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.prefetchDataSource = self
    }
    
    private func updateFeed() {
        FeedService.shared.update(feed: feed, by: offset, type: .viewed) { [weak self] feed, error in
            if error != nil {
                print("Couldn't update feed")
                return
            }
            self?.tableView.reloadData()
        }
    }
    
    private func isLoadingCell(at indexPath: IndexPath) -> Bool {
        return indexPath.row >= feed.articles.count
    }
}

extension BaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.totalArticles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell
        if isLoadingCell(at: indexPath) {
            cell.configure(with: nil)
        } else {
            let article = feed.articles[indexPath.row]
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
}
