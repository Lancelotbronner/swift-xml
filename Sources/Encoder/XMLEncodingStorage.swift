
//
//  XMLEncodingStorage.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/22/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// MARK: - Encoding Storage and Containers

struct _XMLEncodingStorage {
	
	/// The container stack.
	/// Elements may be any one of the XML types (NSNull, NSNumber, NSString, NSArray, NSDictionary).
	private(set) var containers: [NSObject] = []
	
	/// Initializes `self` with no containers.
	init() {}
	
	var count: Int {
		return self.containers.count
	}
	
	mutating func pushKeyedContainer() -> NSMutableDictionary {
		let dictionary = NSMutableDictionary()
		self.containers.append(dictionary)
		return dictionary
	}
	
	mutating func pushUnkeyedContainer() -> NSMutableArray {
		let array = NSMutableArray()
		self.containers.append(array)
		return array
	}
	
	mutating func push(container: NSObject) {
		self.containers.append(container)
	}
	
	mutating func popContainer() -> NSObject {
		precondition(!self.containers.isEmpty, "Empty container stack.")
		return self.containers.popLast()!
	}
}
