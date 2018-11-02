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

	
	internal var owner:User!
	internal var uid:String!
	
	internal var profileImageView:UIImageView!

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
		self.uid = uid
		Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) {
			(snapshot) in
			
			if let dictionary = snapshot.value as? [String:AnyObject] {
			
				// для отрисовки навбара нужны данные по юзеру
				let user = User()
				user.setValuesForKeys(dictionary)
				self.setupNavbarWithUser(user: user)
				self.owner = user
			}
		}
	}
	
	
	
	/// Отрисовка навбара с картинкой
	internal func setupNavbarWithUser(user: User){
		
		// контейнер
		let titleView = UIView()
		titleView.frame = CGRect(x: 0, y: 0, width: 160, height: 40)
//		titleView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).withAlphaComponent(0.5)
		
		// еще один контейнер (чтоб всё что внутри растягивалось на всё свободное место навбара)
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		self.navigationItem.titleView = titleView
		titleView.addSubview(containerView)
		
		containerView.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
		containerView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
		containerView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
		containerView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
		
		// фотка
		profileImageView = UIImageView()
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.layer.cornerRadius = 18
		profileImageView.clipsToBounds = true
		
		if let profileImageUrl = user.profileImageUrl {
			profileImageView.loadImageUsingCache(urlString: profileImageUrl, completionHandler: nil)
		}
		containerView.addSubview(profileImageView)
		// добавим констраинты для фотки в контейнере
		profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
		
		// лейбла с именем
		let nameLabel = UILabel()
		nameLabel.text = user.name
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(nameLabel)
		
		nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
		nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
		nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		
		self.navigationItem.titleView = titleView
		
		// добавим клик к фотке для изменения ее
		titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPhotoClick(sender:))))
		titleView.isUserInteractionEnabled = true
		
	}


//	override var intrinsicContentSize: CGSize {
//		return CGSize(width: 150, height: 36)
//	}

	
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







/// в 11 иос не проходит тап по тайтлвью!!!!
extension MessagesController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	@objc internal func onPhotoClick(sender: UITapGestureRecognizer){
		
		let picker = UIImagePickerController()
		
		picker.delegate = self
		picker.allowsEditing = true
		
		present(picker, animated: true, completion: nil)
	}
	
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		var selectedImage:UIImage?
		
		if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
			selectedImage = editedImage
		}
		else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
			selectedImage = originalImage
		}
		
		if let selectedImage = selectedImage {
			profileImageView.image = selectedImage
			saveProfileImage(imag: selectedImage)
		}
		dismiss(animated: true, completion: nil)
	}
	
	
	
	
	
	/// сохраняем новую картику в БД, обновляем ссылку на нее в БД и здесь
	internal func saveProfileImage(imag:UIImage){
		
		let oldLink = owner.profileImageUrl
		
		let uniqueImageName = UUID().uuidString // создает уникальное имя картинке
		let storageRef = Storage.storage().reference().child("profile_images").child("\(uniqueImageName).jpg")
		
		// сохраняем картинку в хранилище
		if let uploadData = UIImageJPEGRepresentation(imag, 0.5){
			storageRef.putData(uploadData, metadata: nil, completion: {
				(metadata, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
				// когда получаем метадату, даем запрос на получение ссылки на эту картинку (разработчкики Firebase 5 - дауны)
				storageRef.downloadURL(completion: {
					(url, errorFromGettinfPicLink) in
					
					if let errorFromGettinfPicLink = errorFromGettinfPicLink {
						print(errorFromGettinfPicLink.localizedDescription)
						return
					}
					// обновляем ссылку на скачивание здесь и в БД
					self.owner.profileImageUrl = url!.absoluteString
					
					let ref = Database.database().reference(withPath: "users").child(self.uid).child("profileImageUrl")
					ref.setValue(url!.absoluteString)
					
					// удаляем старую картинку
					if oldLink != "none" {
						let storageRef = Storage.storage().reference(forURL: oldLink!)
						storageRef.delete(completion: nil)
					}
				})
				print("удачно сохранили картинку")
			})
		}
		
		
	}
	
	
}
















