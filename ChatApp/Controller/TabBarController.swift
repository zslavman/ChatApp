//
//  TabBarController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 10.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit



class TabBarController: UITabBarController, UITabBarControllerDelegate {
	
	let names:[String] = ["Чаты", "Контакты", "Настройки"]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		delegate = self
		
		let tab1 = createTab(vc: MessagesController(), buttonImage_unselected: "bttn_menu", title: names[0])
		let tab2 = createTab(vc: FindUserForChatController(), buttonImage_unselected: "bttn_find_user", title: names[1])
//		let tab3 = createTab(vc: SettingsController(), buttonImage_unselected: "bttn_settings", title: names[2])
		
		
		let tableViewStoryboard = UIStoryboard(name: "tBoard", bundle: nil)
		let customViewController = tableViewStoryboard.instantiateViewController(withIdentifier: "myTable")
		let tab3 = createTab(vc: customViewController, buttonImage_unselected: "bttn_settings", title: names[2])
		
		
		viewControllers = [tab1, tab2, tab3]
		
		switchTabTitles(for: view.frame.size)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	

	

	
	
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
		guard let fromView = selectedViewController?.view, let toView = viewController.view else {
			return false
		}
		if fromView != toView {
			UIView.transition(from: fromView, to: toView, duration: 0.0, options: [.transitionCrossDissolve], completion: nil)
		}
		return true
	}
	
	
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		switchTabTitles(for: size)
	}
	

	
	
	private func switchTabTitles(for size: CGSize){
		
		guard let items = tabBar.items else { return }
		
		for index in items.indices {
			if size.width < size.height {
				items[index].title = names[index]
			}
			else {
				items[index].title = ""
			}
		}
	}
	
	
	
	
	
	
	private func createTab(vc:UIViewController, buttonImage_unselected:String, title:String) -> UINavigationController {
		let navController = UINavigationController(rootViewController: vc)
		navController.tabBarItem.image = UIImage(named: buttonImage_unselected)
		// navController.tabBarItem.selectedImage = UIImage(named: buttonImage_selected)
		navController.tabBarItem.title = title
		return navController
	}
	
	
}



















