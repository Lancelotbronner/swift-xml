//
//  XMLKeyedDecodingContainer.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct _XMLKeyedDecodingContainer<Key: CodingKey> {
	
	/// A reference to the storage we're decoding from.
	private let storage: _XMLDecodingStorage
	
	/// Initializes `self` by referencing the given decoder and container.
	init(referencing storage: _XMLDecodingStorage) {
		self.storage = storage
	}
	
}

extension _XMLKeyedDecodingContainer : KeyedDecodingContainerProtocol {
	
	@inlinable
	public var codingPath: [any CodingKey] {
		storage.codingPath
	}
	
	@inlinable
	public var allKeys: [Key] {
		guard let container = try? storage.get(Any.self) else { return [] }
		return container.children.compactMap { Key(stringValue: $0.key) }
	}
	
	@inlinable
	public func contains(_ key: Key) -> Bool {
		guard let container = try? storage.get(Any.self) else { return false }
		return container.children.contains { $0.key == key.stringValue }
	}
	
	@inlinable
	public func decodeNil(forKey key: Key) throws -> Bool {
		false
	}
	
	@inlinable
	public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode(_ type: String.Type, forKey key: Key) throws -> String {
		try storage.with(key) {
			try storage.decode()
		}
	}
	
	public func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
		try storage.with(key) {
			try storage.decodeCompound()
		}
	}
	
	public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
		try storage.with(key) {
			storage.keyedContainer()
		}
	}
	
	public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		try storage.with(key) {
			storage.unkeyedContainer()
		}
	}
	
	@inlinable
	public func superDecoder() throws -> Decoder {
		try storage.with(_CodingKey.super) {
			storage.singleValueContainer()
		}
	}
	
	@inlinable
	public func superDecoder(forKey key: Key) throws -> Decoder {
		try storage.with(key) {
			storage.singleValueContainer()
		}
	}
}
