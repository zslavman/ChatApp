//
//  MessageController_HiddenMenu.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 03.01.2019.
//  Copyright © 2019 Zinko Vyacheslav. All rights reserved.
//

import UIKit

// менюшка по клику на rightBarButtonItem
extension MessagesController: UIPopoverPresentationControllerDelegate, PopoverMunuClickedDelegate {
	
	@objc private func onMenuClick(){
		
		rotateRightBarButton()
		
		let menuVC = PopOverMenu()
		menuVC.modalPresentationStyle = .popover
		menuVC.popoverMunuClickedDelegate = self
		
		guard let popOverVC = menuVC.popoverPresentationController else { return }
		popOverVC.delegate = self
		popOverVC.barButtonItem = navigationItem.rightBarButtonItem
		
		// если цель не BarButtonItem
		// popOverVC.sourceView = someBttn // для треугольного указателя
		// popOverVC.sourceRect = CGRect(x: someBttn.bounds.midX, y: someBttn.bounds.maxY, width: 0, height: 0)
		
		present(menuVC, animated: true)
	}
	
	// без этого метода на ифонах поповер откроется на весь экран (на айпадах будет норм и без этого)
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
	
	
	// метод PopoverMunuClickedDelegate
	func cellClicked(numberOfMenu: Int) {
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			switch numberOfMenu {
			case 0:
				SUtils.animateTableWithSections(tableView: self.tableView)
			case 1:
				self.isOnline = !self.isOnline
				OnlineService.setUserStatus(self.isOnline)
				self.navigationItem.titleView?.alpha = self.isOnline ? 1 : 0.35
			case 2:
				let vc = JSONTable()
				let navContr = UINavigationController(rootViewController: vc)
				self.present(navContr, animated: true, completion: nil)
			case 3:
				let alertController = Notifications.shared.createNotif()
				self.present(alertController, animated: true, completion: nil)
			default: fatalError()
			}
		}
	}
	
	
	
	
	
	// создание кнопки админского меню
	internal func createBarItem(){
		
		guard owner.id! == "KxDQNTywa9ghlyBPvEmIa7oQZ0G3" else { return }
		
		let button = UIButton(type: .custom)
		if let image = UIImage(named:"bttn_menu") {
			button.setImage(image, for: .normal)
		}
		button.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // без этого в iOS10 кнопка невидна
		button.addTarget(self, action: #selector(onMenuClick), for: .touchUpInside)
		let barButton = UIBarButtonItem(customView: button)
		navigationItem.rightBarButtonItem = barButton
		
		appearanceRightBarButton()
	}
	
	
	
	
	// анимация появления кнопки админского меню
	internal func appearanceRightBarButton(){
		
		navigationItem.rightBarButtonItem?.isEnabled = true
		navigationItem.rightBarButtonItem?.tintColor = UIColor.white
		
		// анимация появления
		navigationItem.rightBarButtonItem?.customView!.transform = CGAffineTransform(scaleX: 0, y: 0)
		// при анимации кнопка перестает быть кнопкой, потому принудительно делаем ей allowUserInteraction
		UIView.animate(
			withDuration			: 1.0,
			delay					: 0.3,
			usingSpringWithDamping	: 0.5,
			initialSpringVelocity	: 10,
			options					: .curveLinear,
			animations: {
				self.navigationItem.rightBarButtonItem?.customView!.transform = CGAffineTransform.identity
		}
		)
	}
	
	
	
	internal func rotateRightBarButton(){
		navigationItem.rightBarButtonItem?.customView!.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 6/5))
		UIView.animate(withDuration: 0.3) {
			self.navigationItem.rightBarButtonItem?.customView!.transform = CGAffineTransform.identity
		}
	}
	
	
}




















