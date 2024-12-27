//
//  XMLDecodingStorage.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct _XMLDecodingStorage {

    /// The container stack.
    /// Elements may be any one of the XML types (String, [String : Any]).
    private(set) var containers: [Any] = []

    /// Initializes `self` with no containers.
    init() {}

    var count: Int {
        return self.containers.count
    }

    var topContainer: Any {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.last!
    }

    mutating func push(container: Any) {
        self.containers.append(container)
    }

    mutating func popContainer() {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        self.containers.removeLast()
    }
}
