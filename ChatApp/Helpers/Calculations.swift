//
//  Calculations.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 02.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import Foundation
import Firebase


struct Calculations {
	
	
	
	/// выдирает ключи из снапшота в строковый массив
	static func extractKeysToArray(snapshot:[DataSnapshot]) -> [String]{
		
		var keyStrings = [String]()
		
		for child in snapshot {
			let nam = child.key
			keyStrings.append(nam)
		}
		keyStrings = snapshot.map({$0.key})
		
		return keyStrings
	}
	
	
	
	/// получаем класс со строки
	static func stringClassFromString(className: String) -> AnyClass! {
		
		/// get namespace
		let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
		
		let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!
		
		return cls
	}
	
	
	
	
	
}








