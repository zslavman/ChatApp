//
//  DeviceOrientationHelper.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 18.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit


struct AppUtility {
	
	static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
		if let delegate = UIApplication.shared.delegate as? AppDelegate {
			delegate.orientationLock = orientation
		}
	}
	
	/// OPTIONAL Added method to adjust lock and rotate to the desired orientation
	static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
		self.lockOrientation(orientation)
		UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
	}
	
}
