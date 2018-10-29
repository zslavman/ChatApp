//
//  ViewController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(onLogout))
		
	}


	
	@objc private func onLogout(){
		let loginController = LoginController()
		present(loginController, animated: true, completion: nil)
		
		
	}


}

