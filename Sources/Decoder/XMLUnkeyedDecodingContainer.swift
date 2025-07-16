//
//  XMLUnkeyedDecodingContainer.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct _XMLUnkeyedDecodingContainer {
	
	/// A reference to the storage we're decoding from.
	private let storage: _XMLDecodingStorage
	
	/// The index of the element we're about to decode.
	public private(set) var currentIndex: Int
	
	/// Initializes `self` by referencing the given decoder and container.
	init(referencing storage: _XMLDecodingStorage) {
		self.storage = storage
		self.currentIndex = 0
	}
	
}

extension _XMLUnkeyedDecodingContainer : UnkeyedDecodingContainer {
	
	
	public var count: Int? {
		try? storage.get(Any.self).children.count
	}
	
	public var isAtEnd: Bool {
		currentIndex >= count ?? 0
	}
	
	public var codingPath: [any CodingKey] {
		storage.codingPath
	}
	
	public mutating func decodeNil() throws -> Bool {
		isAtEnd
	}
	
	public mutating func decode(_ type: Bool.Type) throws -> Bool {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: Int.Type) throws -> Int {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: Int8.Type) throws -> Int8 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: Int16.Type) throws -> Int16 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: Int32.Type) throws -> Int32 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: Int64.Type) throws -> Int64 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: UInt.Type) throws -> UInt {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: Float.Type) throws -> Float {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: Double.Type) throws -> Double {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode(_ type: String.Type) throws -> String {
		try storage.with(&currentIndex) {
			try storage.decode()
		}
	}
	
	public mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
		try storage.with(&currentIndex) {
			try storage.decodeCompound()
		}
	}
	
	public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
		try storage.with(&currentIndex) {
			storage.keyedContainer()
		}
	}
	
	public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
		try storage.with(&currentIndex) {
			storage.unkeyedContainer()
		}
	}
	
	public mutating func superDecoder() throws -> Decoder {
		try storage.with(&currentIndex) {
			storage.singleValueContainer()
		}
	}
}
