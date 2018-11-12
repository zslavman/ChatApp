//
//  Message.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 06.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


class Message: NSObject {

	@objc public var fromID:String?
	@objc public var toID:String?
	@objc public var timestamp:NSNumber?
	@objc public var text:String?
	
	@objc public var imageUrl:String?
	@objc public var imageWidth:NSNumber?
	@objc public var imageHeight:NSNumber?
	
	
	
	public func chatPartnerID() -> String? {
		return fromID == Auth.auth().currentUser?.uid ? toID : fromID
	}

	
	init(dictionary: [String:Any]){
		super.init()
		
		fromID 		= dictionary["fromID"] as? String
		toID 		= dictionary["toID"] as? String
		timestamp 	= dictionary["timestamp"] as? NSNumber
		text 		= dictionary["text"] as? String
		
		imageUrl 	= dictionary["imageUrl"] as? String
		imageWidth 	= dictionary["imageWidth"] as? NSNumber
		imageHeight 	= dictionary["imageHight"] as? NSNumber
	}
	
	
	
}
