//
//  User.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 31.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class User: NSObject {

	// @objc - для того чтоб воспользоваться методом setValuesForKeys, который заполнит эти значения
	@objc public var name:String?
	@objc public var email:String?
	@objc public var profileImageUrl:String?
	@objc public var id:String? // устанавливается вручную
	@objc public var isOnline:Bool = false
	@objc public var fcmToken:String?
	

	
	
	
	
	
}
