//
//  PushStaticMethods.swift
//  ChatApp
//
//  Created by Zinko Viacheslav on 17.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//
import Foundation

// This is a separate class just only for widget "PushMutater"!!

class PushStaticMethods {
	
	public static func stringTime() -> String {
		let currentTime = Date()
		let dateFormater = DateFormatter()
		dateFormater.dateFormat = "HH:mm:ss"
		let hh_mm = dateFormater.string(from: currentTime)
		return hh_mm
	}
	
}
