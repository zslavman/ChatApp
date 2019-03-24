//
//  Notifications.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 03.01.2019.
//  Copyright © 2019 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseMessaging


class Notifications: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
	
	public static let shared = Notifications()
	public let notif_ID:String = "notif_ID"
	private let NotifCenter = UNUserNotificationCenter.current()
	
	
	// запрос на нотификейшны
	public func requestAuthorisation(){
		
		UNUserNotificationCenter.current().delegate = self
		Messaging.messaging().delegate = self
		
		let options: UNAuthorizationOptions = [.alert, .badge, .sound]
		NotifCenter.requestAuthorization(options: options, completionHandler: {
			authorized, error in
			
			#if targetEnvironment(simulator)
			// code for simulator
			#else
			if authorized {
				DispatchQueue.main.async {
					//application.registerForRemoteNotifications()
					UIApplication.shared.registerForRemoteNotifications()
				}
			}
			#endif
		})
	}
	
	
	
	// создаем алертконтроллер для запуска уведомления
	public func createNotif() -> UIAlertController {
		
		let title = "Запуск уведомления"
		let message = "Введите кол-во секунд, через которое сработает уведомление. После нажатия 'ОК' приложение' будет закрыто:"
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addTextField {
			textField in
			textField.keyboardType = .numberPad
			textField.layer.cornerRadius = 8
			textField.clipsToBounds = true
			textField.placeholder = "1 - 999"
			textField.font = UIFont.systemFont(ofSize: 20)
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 30))
			textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
			textField.leftViewMode = .always
		}
		
		let OK_action = UIAlertAction(title: "OK", style: .default, handler: {
			(action) in

			let textField = alertController.textFields?[0]
			let receivedStr = Double(textField!.text!)
			
			if let number = receivedStr{
				if !number.isNaN && number > 0 && number < 1000{
					self.sendLocalNotif(delaySeconds: number)
				}
			}
		})
		let CANCEL_action = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		CANCEL_action.setValue(UIColor.red, forKey: "titleTextColor")
		
		alertController.addAction(OK_action)
		alertController.addAction(CANCEL_action)
		
		return alertController
	}

	
	
	// отправить локальное уведомление через Х секунд
	public func sendLocalNotif(delaySeconds:TimeInterval){
		
		// чистим предыдущие уведомления (если таковые будут)
		removeNotifications(identifiers: [notif_ID])
		
		// создаем время срабатывания
		let thresholdDate = Date(timeIntervalSinceNow: delaySeconds) // дата срабатывания = (now + delay)
		
		// наполняем контентом уведомление
		let notifContent = UNMutableNotificationContent()
		notifContent.title = "Сообщение из Прекрасного Далёка:"
		notifContent.body = "Эники, левисы, гучи, три выпавшие плобмы. Диагноз?"
		notifContent.sound = UNNotificationSound(named: convertToUNNotificationSoundName("pipk.mp3"))
		
		// создаем триггер
		let dComponent = Calculations.getDateComponent(fromDate: thresholdDate)
		let trigger = UNCalendarNotificationTrigger(dateMatching: dComponent, repeats: false)
		
		let request = UNNotificationRequest(identifier: notif_ID, content: notifContent, trigger: trigger)
	
		// добавляем запрос в нотиф.центр
		NotifCenter.add(request) {
			(error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			print("Оповещение сработает через: \(Int(delaySeconds))с")
		}
		
		// выходим из приложения через 0.5 с
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
		}
	}
	

	deinit {
		print("deinit Notifications.class")
		removeNotifications(identifiers: [notif_ID])
	}
	
	
	
	// читаем архив оповещений которые еще не произошли
	// и находим там (если есть) время прошлого нотификейшна
	public func getLastNotifData(callback: ((Double) -> ())?){
		
		var lastReceivedNotifTime:DateComponents?
		
		NotifCenter.getPendingNotificationRequests {
			(launchedNotifSet:[UNNotificationRequest]) in
			
			for request in launchedNotifSet {
				if request.identifier == self.notif_ID {
					lastReceivedNotifTime = request.trigger?.value(forKey: "dateComponents") as? DateComponents
					break
				}
			}
			
			if let lastReceivedNotifTime = lastReceivedNotifTime {
				let estimateTime = Calendar.current.dateComponents([.minute, .second], from: Calculations.getDateComponent(), to: lastReceivedNotifTime)
				print("estimateTime = \(estimateTime)")
				let minutes = estimateTime.minute!
				let seconds = estimateTime.second!
				
				let summ = minutes*60 + seconds
				let converted = Calculations.convertTime(seconds: Double(summ))
				
				print("seconds = \(summ)")
				print("converted = \(converted)")
				
				if (callback != nil){
					callback!(Double(summ))
				}
			}
		}
	}
	
	
	private func removeNotifications(identifiers:[String]){
		getLastNotifData(callback: nil)
		NotifCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
	}
	

	public func ConnectToFCM() {
		Messaging.messaging().shouldEstablishDirectChannel = true
	}
	
	
	//***********************************
	// UNUserNotificationCenterDelegate *
	//***********************************
	
	/// show popup notification for foreground only
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)	{
		var notifOptions: UNNotificationPresentationOptions = [.alert]
		if UserDefFlags.sound_mess {
			notifOptions.insert(.sound)
		}
		if let senderID = MessagesController.shared.goToChatWithID {
			let payload = notification.request.content.userInfo
			let senderFromNotif = payload["fromID"] as! String
			if senderID == senderFromNotif {
				notifOptions = []
			}
		}
		completionHandler(notifOptions)
	}
	
	
	/// tap on popup notification
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		let payload = response.notification.request.content.userInfo
		let senderFromNotif = payload["fromID"] as! String
		
		guard let window = UIApplication.shared.keyWindow else { return }
		
		if let tabBarController = window.rootViewController?.children.first as? TabBarController {
			// if user inside chatroom - close current dialog
			if MessagesController.shared.goToChatWithID != nil {
				MessagesController.shared.navigationController?.popViewController(animated: false)
			}
			else {
				// switch tab to first
				tabBarController.selectedIndex = 0
			}
		}
		// try to find need sender
		let findUser = MessagesController.shared.senders.filter{ $0.id == senderFromNotif }
		if let needUser = findUser.first {
			// for increment unread count fill savedIndexPath (it will be (0, 0) always bcs it sorting when got new message)
			MessagesController.shared.savedIndexPath = IndexPath(row: 0, section: 0)
			MessagesController.shared.goToChatWith(user: needUser)
		}
		completionHandler()
	}
	
	
	
	
	//********************
	// MessagingDelegate *
	//********************
	
	// внутренние сообщения FCM
	func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
		print("didReceive remoteMessage:")
	}
	// doesn't work
	func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
		print("Refreshed Token: \(fcmToken)")
	}
	// doesn't work
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		print("fcmToken = \(fcmToken)")
		ConnectToFCM()
	}
	
}


extension AppDelegate {
	
	// threshold if "content_available" : true  only
	/// receive silent push (recount unread, update bage number)
	func application(_ application: UIApplication,
					 didReceiveRemoteNotification userInfo: [AnyHashable : Any],
					 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		
		// send analitic to FCM
		Messaging.messaging().appDidReceiveMessage(userInfo)
		
		if UIApplication.shared.applicationState == .background {
			if MessagesController.shared != nil {
				MessagesController.shared.countUnreadInBackground(from: userInfo["fromID"] as! String)
			}
		}
		completionHandler(UIBackgroundFetchResult.newData)
	}
}
























// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUNNotificationSoundName(_ input: String) -> UNNotificationSoundName {
	return UNNotificationSoundName(rawValue: input)
}
