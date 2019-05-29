//
//  UIImage + setImage.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/29/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import AlamofireImage

extension UIImageView {
    func setImage(with urlString: String) {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.addSubview(spinner)
        spinner.center = self.center
        
        guard let url = URL(string: urlString) else { return }
        self.af_setImage(withURL: url, imageTransition: .crossDissolve(0.2)) { _ in
            spinner.stopAnimating()
        }
    }
}
