//
//  ArticleTableViewCell.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/29/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: nil)
    }
    
    func configure(with article: Article?) {
        if let article = article {
            titleLabel.text = article.title
            publishedLabel.text = "Published date: \(article.published)"
            if let emailed = article.emailed {
                ratingLabel.text = "Emailed: \(emailed)"
            } else if let shared = article.shared {
                ratingLabel.text = "Shared: \(shared)"
            } else if let viewed = article.viewed {
                ratingLabel.text = "Viewed: \(viewed)"
            }
            thumbImageView.setImage(with: article.thumbImage)
            spinner.stopAnimating()
        } else {
            titleLabel.text = ""
            publishedLabel.text = ""
            thumbImageView.image = nil
            spinner.startAnimating()
        }
    }
}
