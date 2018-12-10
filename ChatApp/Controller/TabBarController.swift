//
//  TabBarController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 10.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit



class TabBarController: UITabBarController {
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let tab1 = createTab(vc: MessagesController(), buttonImage_unselected: "bttn_menu", buttonImage_selected: "bttn_menu")
		let tab2 = createTab(vc: FindUserForChatController(), buttonImage_unselected: "bttn_find_user", buttonImage_selected: "bttn_find_user")
		let tab3 = createTab(vc: SettingsController(), buttonImage_unselected: "bttn_settings", buttonImage_selected: "bttn_settings")
		
		viewControllers = [tab1, tab2, tab3]
	}
	
	
	
	override func viewDidAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	
}





extension TabBarController {
	
	
	internal func createTab(vc:UIViewController, buttonImage_unselected:String, buttonImage_selected:String) -> UINavigationController {
		let navController = UINavigationController(rootViewController: vc)
		navController.tabBarItem.image = UIImage(named: buttonImage_unselected)
		navController.tabBarItem.selectedImage = UIImage(named: buttonImage_selected)
		return navController
	}
	
	
	
}








