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
			fetchUserAndSetupNavbarTitle()
		}
	}
	
	
	
	
	public func fetchUserAndSetupNavbarTitle(){
		
		guard let uid = Auth.auth().currentUser?.uid else {	return } // проверка если user = nil
		
		Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) {
			(snapshot) in
			
			if let dictionary = snapshot.value as? [String:AnyObject] {
			
				// для отрисовки навбара нужны данные по юзеру
				let user = User()
				user.setValuesForKeys(dictionary)
				self.setupNavbarWithUser(user: user)
			}
		}
	}
	
	
	
	/// Отрисовка навбара с картинкой
	internal func setupNavbarWithUser(user: User){
//		self.navigationItem.title = user.name
		
		// контейнер
		let titleView = UIView()
		titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//		titleView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).withAlphaComponent(0.5)
		
		// еще один контейнер (чтоб всё что внутри растягивалось на всё свободное место навбара)
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		titleView.addSubview(containerView)
		
		// фотка
		let profileImageView = UIImageView()
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.layer.cornerRadius = 20
		profileImageView.clipsToBounds = true

		if let profileImageUrl = user.profileImageUrl {
			profileImageView.loadImageUsingCache(urlString: profileImageUrl)
		}
		containerView.addSubview(profileImageView)
		// добавим констраинты для фотки в контейнере
		profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		// лейбла с именем
		let nameLabel = UILabel()
		nameLabel.text = user.name
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(nameLabel)
		
		nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
		nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
		nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
		
		// центруем containerView
		containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
		containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
		
		
		self.navigationItem.titleView = titleView
		
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
		
		// фикс бага когда выходишь и регишся а тайтл не меняется
		loginController.messagesController = self
		
		present(loginController, animated: true, completion: nil)
	}
	
	
	
	
	@objc private func onNewMessageClick(){
		let newMessContr = NewMessageController()
		let navContr = UINavigationController(rootViewController: newMessContr)
		present(navContr, animated: true, completion: nil)
		
		
	}
	
	


}





















