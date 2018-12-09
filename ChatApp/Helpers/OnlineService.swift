//
//  OnlineOfflineService.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 19.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


struct OnlineService {
	
	/// Установка в БД online/offline для owner
	///
	/// - Parameters:
	///   - status: true(online)/false(offline)
	static func setUserStatus(_ status: Bool) {
		
		if let uid = Auth.auth().currentUser?.uid {
			let onlinesRef = Database.database().reference().child("users").child(uid).child("isOnline")
			onlinesRef.setValue(status) {
				(error:Error?, ref:DatabaseReference) in
				
				if let error = error {
					assertionFailure(error.localizedDescription)
				}
				else {
					let str = status ? "online" : "offline"
					print("Юзер: \(str)")
				}
			}
		}
	}
	
	
}
