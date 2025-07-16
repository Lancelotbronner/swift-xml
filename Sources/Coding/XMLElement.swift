//
//  XMLElement.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

@propertyWrapper
public struct XMLElement<Value>: XMLCodable {
	public var wrappedValue: Value
	
	@inlinable public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
	public static var xmlCodingAffinity: XMLCodingAffinity { .element }
}

extension XMLElement: Decodable where Value: Decodable {}
extension XMLElement: Encodable where Value: Encodable {}
