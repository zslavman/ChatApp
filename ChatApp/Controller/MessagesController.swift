//
//  ViewController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

	

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(onLogout))
		
		let bttnImage = UIImage(named: "new_message_icon")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: bttnImage, style: .plain, target: self, action: #selector(onNewMessageClick))
		
		chekIfUserLoggedIn()
		print("viewDidLoad === viewDidLoad")
	}
	


	
	private func chekIfUserLoggedIn(){
		// выходим, если не залогинены
		if Auth.auth().currentUser?.uid == nil{
			perform(#selector(onLogout), with: nil, afterDelay: 0) // для устранения Unbalanced calls to begin/end appearance transitions for <UINavigationController: 0x7f...
		}
		// автологинка
		else {
			let uid = Auth.auth().currentUser?.uid
			Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value) {
				(snapshot) in
				
				if let dictionary = snapshot.value as? [String:AnyObject] {
					self.navigationItem.title = dictionary["name"] as? String
				}
			}
		}
	}
	
	
	
	
	
	@objc private func onLogout(){
		do {
			try Auth.auth().signOut()
		}
		catch let logoutError{
			print(logoutError)
			return
		}
		
		let loginController = LoginController()
		present(loginController, animated: true, completion: nil)
	}
	
	
	
	
	@objc private func onNewMessageClick(){
		let newMessContr = NewMessageController()
		let navContr = UINavigationController(rootViewController: newMessContr)
		present(navContr, animated: true, completion: nil)
		
		
	}
	
	


}





















