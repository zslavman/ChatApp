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
		notifContent.body = "Эники, левисы, гучи, три выпавшие плобмы??"
		notifContent.sound = UNNotificationSound(named: "pipk.mp3")
		
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
			print("Оповещение сработает через: \(delaySeconds)с")
		}
		
		// выходим из приложения через 0.5 с
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			//UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
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
	// тап по оповещению (созданному через Cloud Messaging или вручную, сообщением)
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
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
	
	// сработает только если "content_available" : true
	// пересчитываем кол-во непрочтенных, обновляем бейдж
	func application(_ application: UIApplication,
					 didReceiveRemoteNotification userInfo: [AnyHashable : Any],
					 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		
		// отправляем аналитику сообщений в FCM
		Messaging.messaging().appDidReceiveMessage(userInfo)
		
		if UIApplication.shared.applicationState == .background {
			if MessagesController.shared != nil {
				MessagesController.shared.countUnreadInBackground(from: userInfo["fromID"] as! String)
			}
		}
		completionHandler(UIBackgroundFetchResult.newData)
	}
}






















