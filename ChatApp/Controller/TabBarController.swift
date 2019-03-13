//
//  TabBarController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 10.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit



class TabBarController: UITabBarController, UITabBarControllerDelegate {
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		delegate = self
		
		let tab1 = createTab(vc: MessagesController(), buttonImage_unselected: "bttn_menu")
		let tab2 = createTab(vc: FindUserForChatController(), buttonImage_unselected: "bttn_find_user")
//		let tab3 = createTab(vc: SettingsController(), buttonImage_unselected: "bttn_settings")
		
		let tableViewStoryboard = UIStoryboard(name: "tBoard", bundle: nil)
		let customViewController = tableViewStoryboard.instantiateViewController(withIdentifier: "myTable")
		let tab3 = createTab(vc: customViewController, buttonImage_unselected: "bttn_settings")
		
		viewControllers = [tab1, tab2, tab3]
		
		switchTabTitles(for: view.frame.size)
	}
	
	override func viewDidAppear(_ animated: Bool) { // прячем навбар от таббарконтроллера, т.к. у нас есть свой
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	

	
	
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
		guard let fromView = selectedViewController?.view, let toView = viewController.view else {
			return false
		}
		if fromView != toView { // анимация перехода между вкладками
			// UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
		}
		return true
	}
	
	
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		switchTabTitles(for: size)
	}
	

	
	
	public func switchTabTitles(for size: CGSize){
		
		guard let items = tabBar.items else { return }
		
		for index in items.indices {
			if size.width < size.height {
				items[index].title = dict[15 + index]![LANG]
			}
			else {
				items[index].title = ""
			}
		}
	}
	
	
	
	
	
	
	private func createTab(vc:UIViewController, buttonImage_unselected:String) -> UINavigationController {
		let navController = UINavigationController(rootViewController: vc)
		navController.tabBarItem.image = UIImage(named: buttonImage_unselected)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
		// navController.tabBarItem.selectedImage = UIImage(named: buttonImage_selected)
		// navController.tabBarItem.title = title
		return navController
	}
	
	
}



















