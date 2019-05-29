//
//  Constants.swift
//  NYTimesArticles
//
//  Created by Denis Verkhovod on 5/28/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation

struct Constants {
    static let baseURL: URL = URL(string: "https://api.nytimes.com/svc/mostpopular/v2")!
    static let emailed: String = "emailed/7.json"
    static let shared: String = "shared/7.json"
    static let viewed: String = "viewed/7.json"
    static let apiKey: String = "api-key"
    static let key: String = "f8zs4wNHqOyEusj4TkXgq0JtJxIYdZRy"
    static let offset: String = "offset"
}
