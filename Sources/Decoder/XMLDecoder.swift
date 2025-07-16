//
//  XMLDecoder.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

/// `XMLDecoder` facilitates the decoding of XML into semantic `Decodable` types.
public struct XMLDecoder {
	/// Initializes `self` with default strategies.
	public init() {}
	
	/// The strategy to use in decoding dates. Defaults to `.secondsSince1970`.
	public var dateDecodingStrategy = DateDecodingStrategy.secondsSince1970
	
	/// The strategy to use in decoding binary data. Defaults to `.base64`.
	public var dataDecodingStrategy = DataDecodingStrategy.base64
	
	/// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
	public var nonConformingFloatDecodingStrategy = NonConformingFloatDecodingStrategy.throw
	
	/// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
	public var keyDecodingStrategy = KeyDecodingStrategy.useDefaultKeys
	
	/// Contextual user-provided information for use during decoding.
	public var userInfo: [CodingUserInfoKey : any Sendable] = [:]
}

public extension XMLDecoder {
	/// Decodes a top-level value of the given type from the given XML representation.
	///
	/// - parameter type: The type of the value to decode.
	/// - parameter data: The data to decode from.
	/// - returns: A value of the requested type.
	/// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid XML.
	/// - throws: An error if any value throws an error during decoding.
	func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
		let parser = _XMLStackParser2(for: self)
		let root: _XMLElement2?
		do {
			root = try parser.parse(with: data)
		} catch {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid XML.", underlyingError: error))
		}
		
		guard let root else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given XML did not contain a root element."))
		}
		
		let storage = _XMLDecodingStorage(of: root, using: self)
		return try storage.decodeCompound()
	}
	
	/// Decodes a top-level value of the given type from the given XML representation.
	///
	/// - parameter type: The type of the value to decode.
	/// - parameter data: The data to decode from.
	/// - returns: A value of the requested type.
	/// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid XML.
	/// - throws: An error if any value throws an error during decoding.
	func decode<T : Decodable>(_ type: T.Type, at rootKey: String, from data: Data) throws -> T {
		let parser = _XMLStackParser2(for: self)
		let root: _XMLElement2?
		do {
			root = try parser.parse(with: data)
		} catch {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid XML.", underlyingError: error))
		}
		
		guard let root else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given XML did not contain a root element."))
		}
		
		guard root.key == rootKey else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Expected root element at '\(rootKey)'."))
		}
		
		let storage = _XMLDecodingStorage(of: root, using: self)
		return try storage.decodeCompound()
	}
}
