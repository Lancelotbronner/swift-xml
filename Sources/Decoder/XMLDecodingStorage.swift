//
//  XMLDecodingStorage.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

final class _XMLDecodingStorage {
	/// A reference to the decoder we're reading from.
	let decoder: XMLDecoder
	
	/// The container stack.
	var containers: [_XMLContainer] = []
	
	/// The current coding path.
	private(set) var codingPath: [any CodingKey] = []
	
	/// Initializes `self` with a root container.
	init(of root: _XMLElement2, using decoder: XMLDecoder) {
		self.decoder = decoder
		containers.append(.node(root))
	}
	
	var count: Int {
		containers.count
	}
	
	var isEmpty: Bool {
		containers.isEmpty
	}
	
	var container: _XMLContainer? {
		containers.last
	}
	
	func with<Result>(
		_ container: _XMLContainer,
		at codingKey: any CodingKey,
		do body: () throws -> Result
	) throws -> Result {
		containers.append(container)
		codingPath.append(codingKey)
		let result = try body()
		containers.removeLast()
		codingPath.removeLast()
		return result
	}
	
	func with<Result>(
		_ codingKey: any CodingKey,
		do body: () throws -> Result
	) throws -> Result {
		let container = try get(Result.self, forKey: codingKey)
		return try with(container, at: codingKey, do: body)
	}
	
	func with<Result>(
		_ index: inout Int,
		do body: () throws -> Result
	) throws -> Result {
		let container = try get(Result.self, at: index)
		let result = try with(container, at: _CodingKey(intValue: index), do: body)
		index += 1
		return result
	}
	
}

extension _XMLDecodingStorage {
	
	private func _errorDescription(of key: CodingKey) -> String {
		switch decoder.keyDecodingStrategy {
		case .convertFromSnakeCase:
			// In this case we can attempt to recover the original value by reversing the transform
			let original = key.stringValue
			let converted = XMLEncoder.KeyEncodingStrategy._convertToSnakeCase(original)
			if converted == original {
				return "\(key) (\"\(original)\")"
			} else {
				return "\(key) (\"\(original)\"), converted to \(converted)"
			}
		default:
			// Otherwise, just report the converted string
			return "\(key) (\"\(key.stringValue)\")"
		}
	}
	
	func get<T>(_ type: T.Type) throws(DecodingError) -> _XMLContainer {
		guard let result = containers.last else {
			throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
		}
		return result
	}
	
	func get<T>(_ type: T.Type, forKey key: any CodingKey) throws(DecodingError) -> _XMLContainer {
		let container = try get(T.self).container(key)
		
		guard let container else {
			throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
		}
		return container
	}
	
	func get<T>(_ type: T.Type, at i: Int) throws(DecodingError) -> _XMLContainer {
		let container = try get(T.self).container(at: i)
		
		guard let container else {
			throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath + [_CodingKey(intValue: i)], debugDescription: "Unkeyed container is at end."))
		}
		return container
	}
	
	func decode() throws(DecodingError) -> String {
		let container = try get(String.self)
		guard let value = container.value else {
			throw DecodingError._typeMismatch(at: codingPath, expectation: String.self, reality: container)
		}
		return value
	}
	
	func decode() throws(DecodingError) -> Bool {
		let value: String = try decode()
		guard let result = Bool(value) else {
			switch value.uppercased() {
			case "YES", "1", "ON": return true
			case "NO", "0", "OFF": return false
			default: break
			}
			throw DecodingError._typeMismatch(at: codingPath, expectation: Bool.self, reality: value)
		}
		return result
	}
	
	func decode<T: LosslessStringConvertible>(_ type: T.Type = T.self) throws(DecodingError) -> T {
		let value: String = try decode()
		guard let result = T(value) else {
			throw DecodingError._typeMismatch(at: codingPath, expectation: T.self, reality: value)
		}
		return result
	}
	
	func decode<T: FloatingPoint & LosslessStringConvertible>(_ type: T.Type = T.self) throws(DecodingError) -> T {
		let value: String = try decode()
		guard let result = T(value) else {
			if case let .convertFromString(positiveInfinity, negativeInfinity, nan) = decoder.nonConformingFloatDecodingStrategy {
				switch value {
				case positiveInfinity: return .infinity
				case negativeInfinity: return -.infinity
				case nan: return .nan
				default: break
				}
			}
			
			throw DecodingError._typeMismatch(at: codingPath, expectation: T.self, reality: value)
		}
		return result
	}
	
	//TODO: Decode value as date
	
	//	func unbox(_ value: Any, as type: Date.Type) throws -> Date? {
	//		guard !(value is NSNull) else { return nil }
	//
	//		switch self.decoder.dateDecodingStrategy {
	//		case .deferredToDate:
	//			self.storage.push(container: value)
	//			defer { self.storage.popContainer() }
	//			return try Date(from: self)
	//
	//		case .secondsSince1970:
	//			let double = try self.unbox(value, as: Double.self)!
	//			return Date(timeIntervalSince1970: double)
	//
	//		case .millisecondsSince1970:
	//			let double = try self.unbox(value, as: Double.self)!
	//			return Date(timeIntervalSince1970: double / 1000.0)
	//
	//		case .iso8601:
	//			if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
	//				let string = try self.unbox(value, as: String.self)!
	//				guard let date = _iso8601Formatter.date(from: string) else {
	//					throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
	//				}
	//
	//				return date
	//			} else {
	//				fatalError("ISO8601DateFormatter is unavailable on this platform.")
	//			}
	//
	//		case .formatted(let formatter):
	//			let string = try self.unbox(value, as: String.self)!
	//			guard let date = formatter.date(from: string) else {
	//				throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
	//			}
	//
	//			return date
	//
	//		case .custom(let closure):
	//			self.storage.push(container: value)
	//			defer { self.storage.popContainer() }
	//			return try closure(self)
	//		}
	//	}
	
	//TODO: decode value as data
	
	//	func unbox(_ value: Any, as type: Data.Type) throws -> Data? {
	//		guard !(value is NSNull) else { return nil }
	//
	//		switch self.decoder.dataDecodingStrategy {
	//		case .deferredToData:
	//			self.storage.push(container: value)
	//			defer { self.storage.popContainer() }
	//			return try Data(from: self)
	//
	//		case .base64:
	//			guard let string = value as? String else {
	//				throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
	//			}
	//
	//			guard let data = Data(base64Encoded: string) else {
	//				throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
	//			}
	//
	//			return data
	//
	//		case .custom(let closure):
	//			self.storage.push(container: value)
	//			defer { self.storage.popContainer() }
	//			return try closure(self)
	//		}
	//	}
	
	func decodeCompound<T: Decodable>(_ type: T.Type = T.self) throws -> T {
		let decoder = _XMLSingleValueDecodingContainer(referencing: self)
		
		if type as? XMLChoice.Type != nil {
			let container = try get(T.self)
			containers.append(container.applying(affinity: .choice))
			let result = try T(from: decoder)
			containers.removeLast()
			return result
		}
		
		if let custom = type as? XMLDecodable.Type {
			let c = containers.count
			try custom.decoding(xml: self)
			let result = try T(from: decoder)
			
			while containers.count > c {
				containers.removeLast()
			}
			return result
		}
		
		return try T(from: decoder)
	}
	
	//	func unbox<T : Decodable>(_ value: Any, as type: T.Type) throws -> T? {
	//		let decoded: T
	//		if type == Date.self || type == NSDate.self {
	//			guard let date = try self.unbox(value, as: Date.self) else { return nil }
	//			decoded = date as! T
	//		} else if type == Data.self || type == NSData.self {
	//			guard let data = try self.unbox(value, as: Data.self) else { return nil }
	//			decoded = data as! T
	//		} else if type == URL.self || type == NSURL.self {
	//			guard let urlString = try self.unbox(value, as: String.self) else {
	//				return nil
	//			}
	//
	//			guard let url = URL(string: urlString) else {
	//				throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
	//																		debugDescription: "Invalid URL string."))
	//			}
	//
	//			decoded = (url as! T)
	//		} else if type == Decimal.self || type == NSDecimalNumber.self {
	//			guard let decimal = try self.unbox(value, as: Decimal.self) else { return nil }
	//			decoded = decimal as! T
	//		} else {
	//			self.storage.push(container: value)
	//			defer { self.storage.popContainer() }
	//			return try type.init(from: self)
	//		}
	//
	//		return decoded
	//	}
	
	func singleValueContainer() -> _XMLSingleValueDecodingContainer {
		_XMLSingleValueDecodingContainer(referencing: self)
	}
	
	func unkeyedContainer() -> _XMLUnkeyedDecodingContainer {
		_XMLUnkeyedDecodingContainer(referencing: self)
	}
	
	func keyedContainer<Key: CodingKey>(_ key: Key.Type = Key.self) -> KeyedDecodingContainer<Key> {
		KeyedDecodingContainer(_XMLKeyedDecodingContainer(referencing: self))
	}
	
}
