//
//  FCMService.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 21.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
//import FBSDKLoginKit
import FBSDKCoreKit
import FacebookLogin


struct APIServices {
	
	/// устанавливаем новый токен
	static func setNewToken(callback: @escaping () -> Void) {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		guard let newToken = Messaging.messaging().fcmToken else { return }
		let tokenRef = Database.database().reference().child("users").child(uid).child("fcmToken")
		
		tokenRef.setValue(newToken) {
			(error: Error?, ref: DatabaseReference) in
			
			if let error = error {
				assertionFailure(error.localizedDescription)
			}
			else {
				print("fcmToken = \(newToken)")
				callback()
			}
		}
	}
	
	
	/// отсылаем оповещение собеседнику
	static func sendNotification(taskDictionary:[String: Any]) {
		let serverKey = "key=AAAAiICxJdI:APA91bFn2XAB9Abz_flynxGP_2OlZ45udFLsKESBOnJOQWl4eeHAWtYEtKRx_eJqj19e0AVsSemlW_5VoKTO0yFsqRV015VwJxna_JqoyX5CEX69-ptOuwacTuFQNZlJJ68HV_uiQp1z"
		guard let url = URL(string:"https://fcm.googleapis.com/fcm/send") else { return }
		
		let bodyToSend:[String : Any] = [
			"content_available"	: true, // important! didReceiveRemoteNotification (inside Appdelegate) couldn't call without this
										// will be converted to: "content-available": 1
			"mutable_content"	: true, // will be converted to: "mutable-content"	: 1
			"priority"			: "high",
			"to"				: taskDictionary["to"] as! String,
			"notification"			: [
				"title" 			: taskDictionary["title"] as! String,
				"body"				: taskDictionary["body"] as! String,
				"sound"				: "pipk.mp3",
				//"badge"			: "1" // change notif before it will be presented
			],
			"data":[
				"fromID": taskDictionary["fromID"] as! String
			],
		]
		var request = URLRequest(url:url)
		request.allHTTPHeaderFields = ["Content-Type":"application/json", "Authorization":"\(serverKey)"]
		request.httpMethod = "POST"
		
		request.httpBody = try? JSONSerialization.data(withJSONObject: bodyToSend, options: [])
		
		URLSession.shared.dataTask(with: request, completionHandler: {
			(data, urlresponse, error) in
			if error != nil{
				print(error!)
			}
		}).resume()
	}
	
	
	// при логауте удаляем на сервере свой токен, чтоб не шли нотификейшны
	public static func removeToken(){
		InstanceID.instanceID().deleteID {
			(error) in
			if let er = error {
				print(er.localizedDescription)
			}
			else {
				print("FCMtoken deleted")
			}
		}
	}
	
	
	/// Set online/offline status for owner
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
	
	
	public static func facebookLogout() {
		guard FBSDKAccessToken.current() != nil else { return }
		let deletePermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, httpMethod: "DELETE")
		deletePermission?.start(completionHandler: {
			(connection, result, error) in
			print("delete permission: \(result ?? "")")
		})
		LoginManager().logOut()
		print("Successfully logged out")
	}
	
	
	public static func fetchFacebookUserInfo() {
		guard FBSDKAccessToken.current() != nil else { return }
		let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture"])
		request?.start(completionHandler: {
			(connection, result, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			let fbDetails = result as! NSDictionary
			print(fbDetails)
		})
	}
		

}



//{
//	"aps": {
//		"alert": "Testing.. (0)",
//		"badge": 1,
//		"sound": "default",
//		"mutable-content": 1
//	}
//}












