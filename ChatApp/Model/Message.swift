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
	
	
	
	public func chatPartnerID() -> String? {
		return fromID == Auth.auth().currentUser?.uid ? toID : fromID
	}

	
	
	
	
	
}
