//
//  XMLAttribute.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

@propertyWrapper
public struct XMLAttribute<Value>: XMLCodable {
	public var wrappedValue: Value
	
	@inlinable public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
	public static var xmlCodingAffinity: XMLCodingAffinity { .attribute }
}

extension XMLAttribute: Decodable where Value: Decodable {}
extension XMLAttribute: Encodable where Value: Encodable {}
