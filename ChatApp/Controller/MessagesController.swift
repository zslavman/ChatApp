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
	private var messages:[Message] = [] 				// общий массив сообщений
	private var messagesDict:[String: Message] = [:] 	// словарь сгруппированных сообщений
	private let cell_id = "cell_id"
	private var timer:Timer? 							// таймер-задержка перезагрузки таблицы
	
	private var refUsers 		= Database.database().reference().child("users")
	private var refMessages 	= Database.database().reference().child("messages")
	private var refUserMessages:DatabaseReference! // ссылка, у которой вконце будет приписан изменяющийся uid
	
	
	private let refUserMessages_original = Database.database().reference().child("user-messages")// начало ссылки для refUserMessages
	
	
	
	
	internal var profileImageView:UIImageView!

	
	// при переходе на другие экраны и возврате сюда - этот метод не дергается!
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(onLogout))
		
		let bttnImage = UIImage(named: "new_message_icon")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: bttnImage, style: .plain, target: self, action: #selector(onNewMessageClick))
		
		chekIfUserLoggedIn()
		
		tableView.register(UserCell.self, forCellReuseIdentifier: cell_id)
		
	}
	
	

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// чтоб до viewDidLoad не отображалась дефолтная таблица
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.backgroundColor = UIColor.white
	}
		
	
	
	
	

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! UserCell
		let msg = messages[indexPath.row]
		
		if msg.toID != nil {
			cell.setupCell(msg: msg, indexPath: indexPath)
		}
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72.0
	}
	
	
	
	/// при клике на диалог (юзера)
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let messag = messages[indexPath.row]
		
		guard let chatPartnerID = messag.chatPartnerID() else { return } 		// достаем ID юзера (кому собираемся писать)
		
		// достаем ссылку на юзера
		refUsers.child(chatPartnerID).observeSingleEvent(of: .value, with: {	// получаем юзера из БД
			(snapshot) in
			
			guard let dict = snapshot.value as? [String: AnyObject] else { return }
			
			let user = User()
			user.setValuesForKeys(dict)
			user.id = chatPartnerID
			
			self.goToChatWith(user: user)
			
		}, withCancel: nil)
	}
	
	
	
	
	/// получаем сообщения с сервера, добавляя слушатель на новые
	private func observeUserMessages(){
		
		if uid == nil { return }
		
		refUserMessages = refUserMessages_original.child(uid)
		
		refUserMessages.observe(.childAdded, with: {
			(snapshot) in
			
			let userID = snapshot.key
			self.refUserMessages = self.refUserMessages_original.child(self.uid).child(userID)
			self.refUserMessages.observe(.childAdded, with: {
				(snapshot) in
				
				let messageID = snapshot.key
				
				self.refMessages.child(messageID).observeSingleEvent(of: .value, with: {
					(snapshot) in
					
					if let dictionary = snapshot.value as? [String:AnyObject] {
						
						// для отрисовки навбара нужны данные по юзеру
						let message = Message()
						message.setValuesForKeys(dictionary)
						self.messages.append(message)
						
						// заполняем словарь и меняем массив
						if let chatPartner = message.chatPartnerID() {
							self.messagesDict[chatPartner] = message
						}
						self.attemptReloadofTable()
					}
				}, withCancel: nil)
				
			}, withCancel: nil)
			
		}, withCancel: nil)
	}
	
	
	
	
	
	
	
	/// фикс бага, когда фото профиля неправильно загружается у пользователей (image flickering)
	/// (без этого таблица перезагружается десятки раз)
	@objc private func delayedRelodTable(){
		messages = Array(self.messagesDict.values)
		messages.sort(by: {
			(message1, message2) -> Bool in
			return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
		})
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	/// попытка перегрузить таблицу
	private func attemptReloadofTable(){
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.delayedRelodTable), userInfo: nil, repeats: false)
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
		refUsers.child(uid).observeSingleEvent(of: .value) {
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
		
		// чистим данные, т.к. если перелогинится под другим юзером они остаются
		messages.removeAll()
		messagesDict.removeAll()
		tableView.reloadData()
		
		observeUserMessages()
		
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
		profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
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
		
		refUsers.removeAllObservers()
		refUserMessages.removeAllObservers()
		refMessages.removeAllObservers()
		
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
		newMessContr.messagesController = self
		let navContr = UINavigationController(rootViewController: newMessContr)
		present(navContr, animated: true, completion: nil)
//		navigationController?.pushViewController(newMessContr, animated: true)
	}
	
	
	@objc public func goToChatWith(user: User){
		let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.user = user
		navigationController?.pushViewController(chatLogController, animated: true)
	}
	
	
}









/// в 11 иос не проходит тап по тайтлвью потому что нужно правильно размещать слои !!!!
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
















