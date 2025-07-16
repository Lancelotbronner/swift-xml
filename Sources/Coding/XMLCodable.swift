//
//  XMLCodable.swift
//  swift-xml
//
//  Created by Christophe Bronner on 2025-07-16.
//

public protocol XMLCodable {
	static var xmlCodingAffinity: XMLCodingAffinity { get }
}

public enum XMLCodingAffinity {
	case none
	case element
	case attribute
	case choice
	case directive
	
	var isSelf: Bool {
		switch self {
		case .choice: true
		default: false
		}
	}
	
	var isElement: Bool {
		switch self {
		case .none, .element: true
		default: false
		}
	}
	
	var isAttribute: Bool {
		switch self {
		case .none, .attribute, .choice: true
		default: false
		}
	}
}

public protocol XMLChoice: XMLCodable {}

public extension XMLChoice {
	static var xmlCodingAffinity: XMLCodingAffinity { .choice }
}

public protocol XMLDirective {}

public extension XMLDirective {
	static var xmlCodingAffinity: XMLCodingAffinity { .directive }
}
