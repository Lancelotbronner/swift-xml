//
//  XMLCoding.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

public protocol XMLCodingAttribute<Value>: CustomReflectable, CustomStringConvertible {
	associatedtype Value
	
	init(wrappedValue: Value)
	
	var wrappedValue: Value { get }
}

public extension XMLCodingAttribute {
	var customMirror: Mirror {
		Mirror(reflecting: wrappedValue)
	}
	
	var description: String {
		"\(wrappedValue)"
	}
}

extension XMLCodingAttribute where Self: Decodable, Value: Decodable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let wrappedValue = try container.decode(Value.self)
		self.init(wrappedValue: wrappedValue)
	}
}

extension XMLCodingAttribute where Self: Encodable, Value: Encodable {
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
	}
}

public extension KeyedDecodingContainer {
	func decode<A: XMLCodingAttribute<T> & Decodable, T: ExpressibleByNilLiteral & Decodable>(_ type: A.Type, forKey key: K) throws -> A {
		if let value = try decodeIfPresent(type, forKey: key) {
			return value
		}
		return A(wrappedValue: nil)
	}
}
