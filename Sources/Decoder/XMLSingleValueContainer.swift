//
//  _XMLDecoder.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2024-12-27.
//

import Foundation

struct _XMLDecoder {
	/// A reference to the storage we're decoding from.
	private let storage: _XMLDecodingStorage
	
	/// Initializes `self` by referencing the given decoder and container.
	init(referencing storage: _XMLDecodingStorage) {
		self.storage = storage
	}
	
	private func _decode<T: LosslessStringConvertible>(_ type: T.Type = T.self) throws(DecodingError) -> T {
		guard !storage.isEmpty else {
			throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
		}
		return try storage.decode()
	}
}

extension _XMLDecoder : Decoder {
	
	@inlinable public var codingPath: [any CodingKey] {
		storage.codingPath
	}
	
	@inlinable public var userInfo: [CodingUserInfoKey : Any] {
		storage.decoder.userInfo
	}
	
	@inlinable public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
		storage.keyedContainer()
	}
	
	@inlinable public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		storage.unkeyedContainer()
	}
	
	@inlinable public func singleValueContainer() throws -> SingleValueDecodingContainer {
		self
	}
}

extension _XMLDecoder : SingleValueDecodingContainer {
	
	public func decodeNil() -> Bool {
		false
	}
	
	public func decode(_ type: Bool.Type) throws -> Bool {
		try storage.decode()
	}
	
	public func decode(_ type: Int.Type) throws -> Int {
		try storage.decode()
	}
	
	public func decode(_ type: Int8.Type) throws -> Int8 {
		try storage.decode()
	}
	
	public func decode(_ type: Int16.Type) throws -> Int16 {
		try storage.decode()
	}
	
	public func decode(_ type: Int32.Type) throws -> Int32 {
		try storage.decode()
	}
	
	public func decode(_ type: Int64.Type) throws -> Int64 {
		try storage.decode()
	}
	
	public func decode(_ type: UInt.Type) throws -> UInt {
		try storage.decode()
	}
	
	public func decode(_ type: UInt8.Type) throws -> UInt8 {
		try storage.decode()
	}
	
	public func decode(_ type: UInt16.Type) throws -> UInt16 {
		try storage.decode()
	}
	
	public func decode(_ type: UInt32.Type) throws -> UInt32 {
		try storage.decode()
	}
	
	public func decode(_ type: UInt64.Type) throws -> UInt64 {
		try storage.decode()
	}
	
	public func decode(_ type: Float.Type) throws -> Float {
		try storage.decode()
	}
	
	public func decode(_ type: Double.Type) throws -> Double {
		try storage.decode()
	}
	
	public func decode(_ type: String.Type) throws -> String {
		try storage.decode()
	}
	
	public func decode<T : Decodable>(_ type: T.Type) throws -> T {
		try storage.decodeCompound()
	}
}
