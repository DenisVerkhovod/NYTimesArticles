//
//  FavoriteViewController.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/31/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    
    var fetchResultsController: NSFetchedResultsController<Article>!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureFetchResultsController()
        configureTableView()
    }
    
    // MARK: - Configure
    private func configure() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Favorite"
    }
    
    private func configureFetchResultsController() {
        let request: NSFetchRequest<Article> = Article.fetchRequest()
        let nameSort = NSSortDescriptor(key: "dateAdded", ascending: false)
        request.sortDescriptors = [nameSort]
        let context = CoreData.stack.mainContext
        fetchResultsController = NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        fetchResultsController.delegate = self
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsConroller \(error)")
        }
    }
    
    private func configureTableView() {
        let cellIdentifier = String(describing: ArticleTableViewCell.self)
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Helpers
    private func notifyAboutRemoveArticle(with title: String) {
        let userInfo = ["title": title] as [String: Any]
        NotificationCenter.default.post(name: .didRemoveFromFavorite, object: nil, userInfo: userInfo)
    }
}

// MARK: - UITableViewDataSource
extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchResultsController.sections else { fatalError("No sections") }
        let count = sections[section].numberOfObjects
        emptyTableLabel.isHidden = count != 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self), for: indexPath) as! ArticleTableViewCell
        let article = fetchResultsController.object(at: indexPath)
        
        cell.configure(with: article)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let _self = self else { return }
            let article = _self.fetchResultsController.object(at: indexPath)
            let title = article.title ?? ""
            article.delete()
            _self.notifyAboutRemoveArticle(with: title)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension FavoriteViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
