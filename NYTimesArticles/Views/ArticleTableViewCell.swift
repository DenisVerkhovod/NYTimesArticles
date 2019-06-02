//
//  ArticleTableViewCell.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/29/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import UIKit

final class ArticleTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var isFavoriteImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: nil)
    }
    
    // MARK: - Configure
    func configure(with article: Article?) {
        if let article = article {
            titleLabel.text = article.title
            if let published = article.published {
                publishedLabel.text = "Published date: \(published)"
            }
            if let emailed = article.emailedIntValue {
                ratingLabel.text = "Emailed: \(emailed)"
            } else if let shared = article.sharedIntValue {
                ratingLabel.text = "Shared: \(shared)"
            } else if let viewed = article.viewedIntValue {
                ratingLabel.text = "Viewed: \(viewed)"
            }
            
            if let localPath = article.thumbImageLocalPath {
                LocalStorageService.shared.image(fromFile: localPath) { [weak self] image in
                    self?.thumbImageView?.image = image
                }
            } else {
                thumbImageView.setImage(with: article.thumbImageLink)
            }
            isFavoriteImageView.isHidden = !article.isInFavorite()
            spinner.stopAnimating()
        } else {
            titleLabel.text = ""
            publishedLabel.text = ""
            ratingLabel.text = ""
            thumbImageView.image = nil
            isFavoriteImageView.isHidden = true
            spinner.startAnimating()
        }
    }
}
