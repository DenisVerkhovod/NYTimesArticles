//
//  ParseService.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 6/2/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import SwiftSoup

final class Parser {
    
    static let shared = Parser()
    
    /// get text from url link
    func text(from path: String?, completion: @escaping ((String?) -> Void)) {
        guard
            let path = path,
            let url = URL(string: path) else {
                completion(nil)
                return
        }
        NetworkService.shared.getData(url: url) { result in
            switch result {
            case let .success(value):
                DispatchQueue.global(qos: .userInitiated).async {
                    let content = String(data: value, encoding: .utf8)
                    do {
                        let doc: SwiftSoup.Document = try SwiftSoup.parse(content ?? "<html></html>")
                        let text: String = try doc.text()
                        DispatchQueue.main.async {
                            completion(text)
                        }
                    } catch {
                        print(error)
                        completion(nil)
                    }
                }
                
            case .failure:
                completion(nil)
            }
        }
    }
}
