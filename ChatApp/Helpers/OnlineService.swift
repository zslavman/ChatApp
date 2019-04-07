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
	public static func setUserStatus(_ status: Bool) {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		let onlinesRef = Database.database().reference().child("users").child(uid)
		var updateDict: [String : Any] = [
			"isOnline" : status
		]
		if !status {
			updateDict["lastVisit"] = Int(Date().timeIntervalSince1970)
		}
		onlinesRef.updateChildValues(updateDict) {
			(error: Error?, ref: DatabaseReference) in
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
