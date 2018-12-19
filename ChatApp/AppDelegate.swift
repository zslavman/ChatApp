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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	public static var waitScreen:WaitScreen!
	public var orientationLock = UIInterfaceOrientationMask.all
	
	
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return self.orientationLock
	}


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		UNUserNotificationCenter.current().delegate = self
		Messaging.messaging().delegate = self
		
		// нотификейшны
		let center = UNUserNotificationCenter.current()
		let options: UNAuthorizationOptions = [.alert, .badge, .sound]
		center.requestAuthorization(options: options, completionHandler: {
			authorized, error in
			
			if authorized {
				application.registerForRemoteNotifications()
				// UIApplication.shared.registerForRemoteNotifications()
			}
		})
		
		FirebaseApp.configure()
		Database.database().isPersistenceEnabled = false
		
		_ = UserDefFlags()
		configureUI()
		
		// не будем использовать сторибоард
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()
		window?.rootViewController = UINavigationController(rootViewController: TabBarController())
		AppDelegate.waitScreen = WaitScreen()
		
		return true
	}

	
	
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	func applicationWillResignActive(_ application: UIApplication) {
		OnlineService.setUserStatus(false)
	}
	

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		Messaging.messaging().shouldEstablishDirectChannel = false
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	func applicationDidBecomeActive(_ application: UIApplication) {
		OnlineService.setUserStatus(true)
		ConnectToFCM()
	}

	
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	func applicationWillTerminate(_ application: UIApplication) {
		OnlineService.setUserStatus(false)
	}
	
	
	

	
	private func configureUI() {
		
		// UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		UINavigationBar.appearance().barTintColor = UIConfig.mainThemeColor
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = false
		UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
		
		UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
		
		// UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
		// UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightGray], for: .normal)
		// UITabBar.appearance().barTintColor = UIConfig.mainThemeColor
		UITabBar.appearance().tintColor = UIConfig.mainThemeColor // иконки при выделении
	}
	
	
	
	// при получении токена
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let tokenParts = deviceToken.map {
			data -> String in
			return String(format: "%02.2hhx", data)
		}
		
		let token = tokenParts.joined()
		print("Device Token: \(token)")
		// ef423b66e7b036165112949b09f2bd4d9535a0bf60d0f6af5f97dc0ec08b110a     - мой
		// 7f3e270f445b1103646828452791fe8a05b317913a7142fa1616e7604505ca14     - ксю
		
		Messaging.messaging().apnsToken = deviceToken
	}
	
	
	// если ошибка при получении токина
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Failed to register: \(error)")
	}
	
	
	
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		ConnectToFCM()
	}
	
	
	func ConnectToFCM() {
		Messaging.messaging().shouldEstablishDirectChannel = true
		
		InstanceID.instanceID().instanceID(handler: {
			(result, error) in
			if let error = error {
				print("Error fetching remote instange ID: \(error)")
			}
			else if let result = result {
				print("Remote instance ID token: \(result.token)")
			}
		})
	}
	
}


extension AppDelegate: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		// 1
		let userInfo = response.notification.request.content.userInfo
		let aps = userInfo["aps"] as! [String: AnyObject]
		
		print("1111111111111111111 = \(aps)")
		completionHandler()
	}
	

	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		
		// отправляем аналитику сообщений в FCM
		Messaging.messaging().appDidReceiveMessage(userInfo)
		//Messaging.messaging().subscribe(toTopic: <#T##String#>)
		
		print(" Entire message \(userInfo)")
		print("Article avaialble for download: \(userInfo["articleId"]!)")
		
		let state : UIApplicationState = application.applicationState
		switch state {
		case UIApplicationState.active:
			print("If needed notify user about the message")
		default:
			print("Run code to download content")
		}
		
		completionHandler(UIBackgroundFetchResult.newData)
	}
	
	
}


extension AppDelegate: MessagingDelegate {
	
	// при получении уведомления (если это "content-available": 1)
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
		print("222222222222222222 = \(userInfo)")
		
		if UIApplication.shared.applicationState == .active {
			//TODO: Handle foreground notification
		}
		else {
			//TODO: Handle background notification
		}
	}
	
}




















