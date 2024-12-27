//
//  XMLKey.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

enum _CodingKey: CodingKey {
	case string(String)
	case int(Int)
	case `super`

	init(codingKey: any CodingKey) {
		self = codingKey.intValue.map(_CodingKey.int) ?? .string(codingKey.stringValue)
	}

	init(stringValue: String) {
		self = .string(stringValue)
	}

	init(intValue: Int) {
		self = .int(intValue)
	}

	var stringValue: String {
		switch self {
		case let .string(key): key
		case let .int(i): "Index \(i)"
		case .super: "super"
		}
	}

	var intValue: Int? {
		switch self {
		case let .int(i): i
		default: nil
		}
	}

	func mapString(do transform: (String) -> String) -> _CodingKey {
		switch self {
		case let .string(key): .string(transform(key))
		default: self
		}
	}
}
