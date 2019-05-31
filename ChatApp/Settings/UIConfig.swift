//
//  UIConfig.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 09.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit


class UIConfig {
	
	static let mainThemeColor = UIColor(r: 45, g: 127, b: 193) // main theme color
	
	public static func configureUI() {
		// UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		UINavigationBar.appearance().barTintColor = UIConfig.mainThemeColor
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = false
		UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		
		UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
		
		// UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
		// UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightGray], for: .normal)
		// UITabBar.appearance().barTintColor = UIConfig.mainThemeColor
		UITabBar.appearance().tintColor = UIConfig.mainThemeColor // иконки при выделении
	}
	
}
