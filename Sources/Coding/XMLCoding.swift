//
//  XMLCoding.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

protocol XMLDecodable {
	static func decoding(xml storate: _XMLDecodingStorage) throws
}

public enum XMLAffinity {
	case node
	case elements
	case attributes
	case value
	case choice
	case directive
}
