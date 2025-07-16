//
//  XMLPropertyWrappers.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

@propertyWrapper
public struct XMLAttribute<Value>: XMLCodingAttribute, XMLDecodable {
	public var wrappedValue: Value
	
	@inlinable public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
	static func decoding(xml storate: _XMLDecodingStorage) throws {
		if let container = storate.container {
			storate.containers.append(container.applying(affinity: .attributes))
		}
	}
}

extension XMLAttribute: Decodable where Value: Decodable {}
extension XMLAttribute: Encodable where Value: Encodable {}

@propertyWrapper
public struct XMLElement<Value>: XMLCodingAttribute, XMLDecodable {
	public var wrappedValue: Value
	
	@inlinable public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
	static func decoding(xml storate: _XMLDecodingStorage) throws {
		if let container = storate.container {
			storate.containers.append(container.applying(affinity: .attributes))
		}
	}
}

extension XMLElement: Decodable where Value: Decodable {}
extension XMLElement: Encodable where Value: Encodable {}

@propertyWrapper
public struct XMLChildren<Value: RangeReplaceableCollection>: XMLCodingAttribute, XMLDecodable {
	public var wrappedValue: Value
	
	@inlinable public init(wrappedValue: Value = Value()) {
		self.wrappedValue = wrappedValue
	}
	
	static func decoding(xml storate: _XMLDecodingStorage) throws {
		guard let key = storate.container?.key else { return }
		storate.containers.removeLast()
		guard let container = storate.container else { return }
		storate.containers.append(.elements(container.elements.filter { $0.key == key }))
	}
}

extension XMLChildren: Decodable where Value: Decodable {}
extension XMLChildren: Encodable where Value: Encodable {}
