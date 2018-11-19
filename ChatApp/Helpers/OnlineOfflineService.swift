//
//  OnlineOfflineService.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 19.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


struct OnlineOfflineService {
	
	/// Установка в БД online/offline для конкретного юзера
	///
	/// - Parameters:
	///   - uid: id юзера
	///   - status: true(online)/false(offline)
	///   - success: метод, который запишет состояние флага в БД
	static func online(for uid: String, status: Bool, success: @escaping (Bool) -> Void) {
		
		let onlinesRef = Database.database().reference().child("users").child(uid).child("isOnline")

		onlinesRef.setValue(status) {
			(error:Error?, ref:DatabaseReference) in
			
			if let error = error {
				assertionFailure(error.localizedDescription)
				success(false)
			}
			success(true)
		}
	}
}
