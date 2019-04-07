//
//  WaitScreen.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 10.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit



class WaitScreen: NSObject {
	
	private var blackView: BlackView!
	
	override init() {
		super.init()
	}
	
	public func show(){
		guard let window = UIApplication.shared.keyWindow else { return }
		blackView = BlackView()
		window.addSubview(blackView)
		blackView.alpha = 0
		
		UIView.animate(withDuration: 0.3) {
			self.blackView.alpha = 1
		}
	}
	
	
	public func hide(){
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			UIView.animate(withDuration: 1, animations: {
				self.blackView.alpha = 0
				self.blackView.transform = CGAffineTransform(scaleX: 2, y: 2)
			}, completion: {
				(bool) in
				self.blackView.removeFromSuperview()
			})
		}
	}
	
	
	public func hideNow(){
		blackView.removeFromSuperview()
	}
	
	
	public func setInfo(str:String) {
		if blackView == nil {
			show()
		}
		blackView.setInfo(str: str)
		hide()
	}
	
	
}

















