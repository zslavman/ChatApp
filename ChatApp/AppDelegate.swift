//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	public static var waitScreen:WaitScreen!


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
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
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	func applicationDidBecomeActive(_ application: UIApplication) {
		OnlineService.setUserStatus(true)
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
	
	
	
	
	


}




















