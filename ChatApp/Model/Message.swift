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
	
	@objc public var videoUrl:String?
	
	public var geo_lat:NSNumber?
	public var geo_lon:NSNumber?
	
	public var unread:Bool?
	
	
	
	public func chatPartnerID() -> String? {
		if fromID == Auth.auth().currentUser?.uid {
			// print("Авторизационный ID совпал с ОТ КОГО")
			return toID
		}
		return fromID
	}

	
	init(dictionary: [String:Any]){
		super.init()
		
		fromID 		= dictionary["fromID"] as? String
		toID 		= dictionary["toID"] as? String
		timestamp 	= dictionary["timestamp"] as? NSNumber
		text 		= dictionary["text"] as? String
		
		imageUrl 	= dictionary["imageUrl"] as? String
		imageWidth 	= dictionary["imageWidth"] as? NSNumber
		imageHeight = dictionary["imageHeight"] as? NSNumber
		
		videoUrl	= dictionary["videoUrl"] as? String
		
		geo_lat 	= dictionary["geo_lat"] as? NSNumber
		geo_lon 	= dictionary["geo_lon"] as? NSNumber
		
		unread 		= dictionary["unread"] as? Bool
	}
	
	
	
	
}

















