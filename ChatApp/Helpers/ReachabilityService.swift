//
//  ReachabilityService.swift
//  ChatApp
//
//  Created by Zinko Viacheslav on 16.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityService {
	
	let reachability = Reachability()!
	public static var isNetworkAvailable = true
	
	init() {
		startMonitoringNetwork()
	}
	
	private func startMonitoringNetwork() {
		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged),
											   name: .reachabilityChanged, object: reachability)
		do {
			try reachability.startNotifier()
		}
		catch {
			print("could not start reachability notifier")
		}
	}
	
	
	@objc private func reachabilityChanged(note: Notification) {
		let reachability = note.object as! Reachability
		switch reachability.connection {
		case .wifi, .cellular:
			print("Reachable via \(reachability.connection)")
			dismissAlertIfAvailable()
		case .none:
			print("Network not reachable!")
			showNetAlert()
		}
	}
	
	private func showNetAlert() {
		ReachabilityService.isNetworkAvailable = false
		let title = "Отсутствует подключени к сети"
		let message = "Для доступа к данным включите передачу данных по сотовой сети или используйте Wi-Fi."
		let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let goToSettingsAction = UIAlertAction(title: "Настройки", style: .default) {
			(action) in
			//self.runUrlSheme(shemeName: UIApplication.openSettingsURLString)
			self.runUrlSheme(shemeName: "App-prefs:root=General&path=Keyboard")
		}
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertVC.addAction(goToSettingsAction)
		alertVC.addAction(okAction)
		
		guard let window = UIApplication.shared.keyWindow else { return }
		guard let viewController = window.rootViewController else { return } // first available VC
		viewController.present(alertVC, animated: true, completion: nil)
	}
	
	private func dismissAlertIfAvailable() {
		ReachabilityService.isNetworkAvailable = true
		guard let window = UIApplication.shared.keyWindow else { return }
		guard let viewController = window.rootViewController else { return }
		guard let nowPresentedVC = viewController.presentedViewController as? UIAlertController else { return }
		nowPresentedVC.dismiss(animated: true, completion: nil)
	}
	
	
	/*
	*  URL-sheme implementation.
	*  Don't forget add into info.plist an array LSApplicationQueriesSchemes with elements (appNames:String)
	*  "chatapp://" - custom, "message://" - native mail client
	*  In case of using transition to iOS paths - you don't need to add any info in playlist
	*/
	private func runUrlSheme(shemeName: String) {
		guard let appURL = URL(string: shemeName) else {
			print("URL-sheme invalid!")
			return
		}
		if UIApplication.shared.canOpenURL(appURL) {
			UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
		}
	}
	
}
