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
import FacebookCore
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	enum ShortcutIdentifier: String {
		case OpenSecret
		case OpenUsers
		
		init?(fullIdentifier: String) {
			guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
				return nil
			}
			self.init(rawValue: shortIdentifier)
		}
	}

	public static var waitScreen: WaitScreen!
	public var window: UIWindow?
	public var orientationLock = UIInterfaceOrientationMask.all
	
	
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return self.orientationLock
	}


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Google sign-in
		GIDSignIn.sharedInstance().clientID = "586274645458-5uli8n92a2lck0bo4hlknv5hiq2l85p6.apps.googleusercontent.com"
		GIDSignIn.sharedInstance().delegate = self
		
		// Facebook sign-in
		SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
		
		FirebaseApp.configure()
		Database.database().isPersistenceEnabled = false
		
		_ = UserDefFlags()
		UIConfig.configureUI()
		
		// don't want to use storyboard
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()
		window?.rootViewController = UINavigationController(rootViewController: TabBarController())
		
		AppDelegate.waitScreen = WaitScreen()
		return true
	}

	
	// сейчас войдет в бэкграунд
	func applicationWillResignActive(_ application: UIApplication) {
		APIServices.setUserStatus(false)
	}
	
	// вошло в бэкграунд
	func applicationDidEnterBackground(_ application: UIApplication) {
		//Messaging.messaging().shouldEstablishDirectChannel = false
	}

	// сейчас вернется в активный режим
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	// вошло в активный режим
	func applicationDidBecomeActive(_ application: UIApplication) {
		APIServices.setUserStatus(true)
		Notifications.shared.ConnectToFCM()
		if MessagesController.shared != nil {
			MessagesController.shared.messages_copy.removeAll()
		}
		AppEventsLogger.activate(application)
	}

	
	// прерывание приложения
	func applicationWillTerminate(_ application: UIApplication) {
		APIServices.setUserStatus(false)
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

	
	// URL-shems handler
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//		print("url = \(url)")
//		let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
//		let host = urlComponents?.host ?? ""
//		print(host)
//		if host == "secretPage" { }
		let canOpenFacebookUrl = SDKApplicationDelegate.shared.application(app, open: url, options: options)
		let canOpenGoogleUrl = GIDSignIn.sharedInstance().handle(
			url,
			sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
			annotation: options[UIApplication.OpenURLOptionsKey.annotation]
		)
		let totalCan = canOpenFacebookUrl ? canOpenFacebookUrl : canOpenGoogleUrl
		
		return totalCan
	}
	
	
	// Universal link handler (Firebase Dynamic Link)
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		guard let url = userActivity.webpageURL else { return false }
		let parsedLink = SUtils.linkParser(url: url)
		SUtils.printDictionary(dict: parsedLink)
		return true
	}
	
	
	/// 3d touch on icon -> menu
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		// open VC from menu
		completionHandler(handleShortcut(shortcutItem))
	}
	@discardableResult fileprivate func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
		if Auth.auth().currentUser?.uid == nil { return false }
		let shortcutType = shortcutItem.type
		guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else { return false	}
		guard let window = UIApplication.shared.keyWindow else { return false }
		guard let tabBarController = window.rootViewController?.children.first as? TabBarController else { return false	}
		switch shortcutIdentifier {
		case .OpenSecret:
			if MessagesController.shared.goToChatWithID != nil {
				MessagesController.shared.navigationController?.popViewController(animated: false)
			}
			else {
				tabBarController.selectedIndex = 0
			}
			MessagesController.shared.createBarItem(skipChecking: true)
			MessagesController.shared.onMenuClick()
			return true
			
		case .OpenUsers:
			tabBarController.selectedIndex = 1
			return true
		}
	}
	
}


extension AppDelegate: GIDSignInDelegate {
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if let error = error {
			print("\(error.localizedDescription)")
		}
		else {
			guard let loginVC = GIDSignIn.sharedInstance()?.uiDelegate as? LoginController else { return }
			loginVC.onLoginViaGoogleResponce(user: user)
		}
	}

}






	

	







	





















