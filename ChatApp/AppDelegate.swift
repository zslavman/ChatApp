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
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

	var window: UIWindow?
	public static var waitScreen:WaitScreen!
	public var orientationLock = UIInterfaceOrientationMask.all
	
	
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return self.orientationLock
	}


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		UNUserNotificationCenter.current().delegate = self
		
		// нотификейшны
		let center = UNUserNotificationCenter.current()
		let options: UNAuthorizationOptions = [.alert, .badge, .sound]
		center.requestAuthorization(options: options, completionHandler: {
			authorized, error in
			
			if authorized {
//				UNUserNotificationCenter.current().delegate = self
				Messaging.messaging().delegate = self
				
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
					// application.registerForRemoteNotifications()
				}
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
		
//		UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		UINavigationBar.appearance().barTintColor = UIConfig.mainThemeColor
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = false
		UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
		
		UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
		
//		UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
//		UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightGray], for: .normal)
//		UITabBar.appearance().barTintColor = UIConfig.mainThemeColor
		UITabBar.appearance().tintColor = UIConfig.mainThemeColor // иконки при выделении
		
	}
	
	
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let tokenParts = deviceToken.map {
			data -> String in
			return String(format: "%02.2hhx", data)
		}
		
		let token = tokenParts.joined()
		print("Device Token: \(token)")
		
		Messaging.messaging().apnsToken = deviceToken
	}
	
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
	
	

	// Called When Cloud Message is Received While App is in Background or is Closed
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		print("response = \(response)")
	}
	
	
	// 
	func application(_ application: UIApplication, didReceiveRemoteNotification: [AnyHashable : Any]) {
		print("didReceiveRemoteNotification = \(didReceiveRemoteNotification)")
	}
	
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		UIApplication.shared.applicationIconBadgeNumber += 1
		
		print("Всего сообщений = \(UIApplication.shared.applicationIconBadgeNumber)")
		
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "organic.ChatApp.BadgeWasUpdated"), object: nil)
	}
	
	
	
	
	


}




















