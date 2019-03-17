//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	
	public static var waitScreen: WaitScreen!
	public var window: UIWindow?
	public var orientationLock = UIInterfaceOrientationMask.all
	
	
	
	
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return self.orientationLock
	}


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		Notifications.shared.requestAuthorisation()
		
		FirebaseApp.configure()
		Database.database().isPersistenceEnabled = false
		
		_ = UserDefFlags()
		UIConfig.configureUI()
		
		// не будем использовать сторибоард
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()
		window?.rootViewController = UINavigationController(rootViewController: TabBarController())
		
		AppDelegate.waitScreen = WaitScreen()
		
		return true
	}

	
	
	// сейчас войдет в бэкграунд
	func applicationWillResignActive(_ application: UIApplication) {
		OnlineService.setUserStatus(false)
	}
	
	// вошло в бэкграунд
	func applicationDidEnterBackground(_ application: UIApplication) {
		Messaging.messaging().shouldEstablishDirectChannel = false
	}

	// сейчас вернется в активный режим
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	// вошло в активный режим
	func applicationDidBecomeActive(_ application: UIApplication) {
		OnlineService.setUserStatus(true)
		Notifications.shared.ConnectToFCM()
		if MessagesController.shared != nil {
			MessagesController.shared.messages_copy.removeAll()
		}
	}

	
	// прерывание приложения
	func applicationWillTerminate(_ application: UIApplication) {
		OnlineService.setUserStatus(false)
	}
	
	

	
	// при получении токена
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		// собираем токен из битов
		let tokenParts = deviceToken.map {
			data -> String in
			return String(format: "%02.2hhx", data)
		}
		
		let token = tokenParts.joined()
		print("Device Token (apnsToken): \(token)")
		
		if let fcmToken = Messaging.messaging().fcmToken {
			print("fcmToken = \(fcmToken)")
		}
		
		Messaging.messaging().apnsToken = deviceToken
		//Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
		
		InstanceID.instanceID().instanceID(handler: {
			(result, error) in
			if let error = error {
				print("Error fetching remote instange ID: \(error)")
			}
			else if let result = result {
				print("instanceIdToken: \(result.token)")
			}
		})
	}
	
	
	// если ошибка при получении токина
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Failed to register: \(error)")
	}
	


	
}






	

	







	





















