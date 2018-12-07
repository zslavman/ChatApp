//
//  Message.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 06.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import NPTableAnimator


//public class Message: NSObject, TableAnimatorCell {
public class Message: TableAnimatorCell {
	
	
	public var hashValue: Int{
		return timestamp!.hashValue
	}
	public typealias UpdateCellType = NSNumber
	public var updateField: NSNumber
	
	public static func == (lhs: Message, rhs: Message) -> Bool {
		return lhs.timestamp! == rhs.timestamp!
	}
	
	
	
	
	// @objc - для использования автозаполнялки (экземпляр.setValuesForKeys) переменных класа
	public var fromID:String?
	public var toID:String?
	public var timestamp:NSNumber?
	public var text:String?
	public var self_ID:String?
	
	public var imageUrl:String?
	public var imageWidth:NSNumber?
	public var imageHeight:NSNumber?
	
	public var videoUrl:String?
	
	public var geo_lat:NSNumber?
	public var geo_lon:NSNumber?
	
	public var readStatus:Bool?
	public var unreadCount:UInt?
	
	
	public func chatPartnerID() -> String? {
		if fromID == Auth.auth().currentUser?.uid {
			// print("Авторизационный ID совпал с ОТ КОГО")
			return toID
		}
		return fromID
	}

	
	init(dictionary: [String:Any]){
//		super.init()
		
		self_ID			= dictionary["self_ID"] as? String
		fromID 			= dictionary["fromID"] as? String
		toID 			= dictionary["toID"] as? String
		timestamp 		= dictionary["timestamp"] as? NSNumber
		text 			= dictionary["text"] as? String
		
		imageUrl 		= dictionary["imageUrl"] as? String
		imageWidth 		= dictionary["imageWidth"] as? NSNumber
		imageHeight 	= dictionary["imageHeight"] as? NSNumber
		
		videoUrl		= dictionary["videoUrl"] as? String
		
		geo_lat 		= dictionary["geo_lat"] as? NSNumber
		geo_lon 		= dictionary["geo_lon"] as? NSNumber
		
		readStatus		= dictionary["readStatus"] as? Bool
		
		updateField = timestamp!
	}
	
}




public struct MySection: TableAnimatorSection {
	
	let id: Int
	
	public var cells: [Message]
	
	public var updateField: Int {
		return 0
	}
	
	subscript(value: Int) -> Message {
		return cells[value]
	}
	
	
	public static func == (lhs: MySection, rhs: MySection) -> Bool {
		// return lhs.id == rhs.id // когда секций больше 1
		return true
	}
	
}

















