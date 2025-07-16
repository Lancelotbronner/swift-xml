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
	case element
	case attribute
	case choice
	case directive
}

public protocol XMLChoice: XMLCodable {}

public extension XMLChoice {
	static var xmlCodingAffinity: XMLCodingAffinity { .choice }
}

public protocol XMLDirective {}

public extension XMLDirective {
	static var xmlCodingAffinity: XMLCodingAffinity { .directive }
}
