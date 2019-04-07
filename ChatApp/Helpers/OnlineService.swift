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
		let onlinesRef = Database.database().reference().child("users").child(uid).child("isOnline")
		onlinesRef.setValue(status) {
			(error: Error?, ref: DatabaseReference) in
			
			if let error = error {
				assertionFailure(error.localizedDescription)
			}
			else {
				let str = status ? "online" : "offline"
				print("Юзер: \(str)")
				if !status {
					setUserLAstVisit()
				}
			}
		}
	}
	
	
	private static func setUserLAstVisit() {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		let currentTimeStamp: Int = Int(Date().timeIntervalSince1970)
		
		let lastVisitRef = Database.database().reference().child("users").child(uid).child("lastVisit")
		lastVisitRef.setValue(currentTimeStamp) {
			(error: Error?, _: DatabaseReference) in
			if let error = error {
				assertionFailure(error.localizedDescription)
			}
			else {
				print("lastVisit = \(currentTimeStamp)")
			}
		}
	}
	
	
}
