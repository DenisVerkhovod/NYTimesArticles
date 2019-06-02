//
//  DetailViewController.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 6/2/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    
    // MARK: - Properties
    var article: Article!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImageview: UIImageView!
    @IBOutlet weak var articleTextView: UITextView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    //MARK: - Configure
    private func configure() {
        navigationController?.navigationBar.prefersLargeTitles = false
        titleLabel.text = article.title ?? ""
        LocalStorageService.shared.image(fromFile: article.imageLocalPath) { [weak self] image in
            self?.mainImageview.image = image
        }
        articleTextView.text = article.text
    }
}
