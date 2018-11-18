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
	private var refUserMessages:DatabaseReference! 		// ссылка, у которой вконце будет приписан изменяющийся uid
	
	
	private let refUserMessages_original = Database.database().reference().child("user-messages")// начало ссылки для refUserMessages
	private var labelNoMessages:UILabel?
	
	private var hendlers = [UInt:DatabaseReference]() 	// для правильного диспоза слушателей базы
	internal var profileImageView:UIImageView!
	private var senders = [User]() 						// данные юзеров с которым есть чаты
	

	
	// при переходе на другие экраны и возврате сюда - этот метод не дергается!
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(onLogout))
		
		let bttnImage = UIImage(named: "new_message_icon")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: bttnImage, style: .plain, target: self, action: #selector(onNewMessageClick))
		
		chekIfUserLoggedIn()
		
		tableView.register(UserCell.self, forCellReuseIdentifier: cell_id)
//		tableView.allowsMultipleSelection = true
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
	
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	/// то, что будет выполнено при нажатии на "удалить"
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		let message = messages[indexPath.row]

		if let partnerID = message.chatPartnerID(){
			refUserMessages_original.child(uid).child(partnerID).removeValue {
				(error, ref) in
				if error != nil {
					print(error!.localizedDescription)
					return
				}
				self.messagesDict.removeValue(forKey: partnerID)
				
				// один из методов обновления таблицы, но он не безопасный
				 self.messages.remove(at: indexPath.row)
				 self.tableView.deleteRows(at: [indexPath], with: .automatic)
				
			}
		}
		
		
		
		
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! UserCell
		let msg = messages[indexPath.row]
		
		if msg.toID != nil {
			cell.iTag = (indexPath.section).description + (indexPath.row).description
			let basePath = cell.iTag
			let _id = msg.chatPartnerID()!
			var _user:User?
			
			// если юзер с _id есть в массиве senders, передаем его в setupCell
			for value in senders {
				if value.id == _id {
					_user = value
					break
				}
			}
			if let _user = _user {
				cell.setupCell(msg: msg, indexPath: indexPath, user: _user)
			}
			// если нет - загружаем его (данные)
			else {
				let ref = Database.database().reference().child("users").child(_id)
				
				ref.observeSingleEvent(of: .value, with: {
					(snapshot:DataSnapshot) in
					
					if let dictionary = snapshot.value as? [String:AnyObject]{
						
						let user = User()
						user.setValuesForKeys(dictionary)
						self.senders.append(user)

						if cell.iTag == basePath {
							cell.setupCell(msg: msg, indexPath: indexPath, user: user)
						}
					}
				})
			}
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

			self.goToChatWith(user: user)

		}, withCancel: nil)
	}
	
	
	
	
	/// получаем сообщения с сервера, добавляя слушатель на новые
	private func observeUserMessages(){
		
		if uid == nil { return }
		
		refUserMessages = refUserMessages_original.child(uid)
		
		// если в БД не будет записей, то в колбэк refUserMessages.observe вообще не зайдет!!
		// потому деграем для смены "Загрузка..."
		drawNoMessages()

		refUserMessages.observe(.childAdded, with: {
			(snapshot) in
			
			let userID = snapshot.key
			let ref_1 = self.refUserMessages_original.child(self.uid).child(userID)
			
			
			let listener = ref_1.observe(.childAdded, with: {
				(snapshot) in
				
				let messageID = snapshot.key
				
				self.refMessages.child(messageID).observeSingleEvent(of: .value, with: {
					(snapshot) in
					
					if let dictionary = snapshot.value as? [String:AnyObject] {
						
						// для отрисовки навбара нужны данные по юзеру
						let message = Message(dictionary: dictionary)
//						message.setValuesForKeys(dictionary)
						self.messages.append(message)
						
						// заполняем словарь и меняем массив
						if let chatPartner = message.chatPartnerID() {
							self.messagesDict[chatPartner] = message
						}
						self.attemptReloadofTable()
					}
				}, withCancel: nil)
				
			}, withCancel: nil)
			
			
			// слушатель на удаление сообщений
			let listener2 = ref_1.observe(.childRemoved, with: {
				(snapshot) in
				
				self.messagesDict.removeValue(forKey: snapshot.key)
				self.attemptReloadofTable()
				
			}, withCancel: nil)
			
			// записываем слушателя и ссылку в словарь (для диспоза)
			self.hendlers[listener] = ref_1
			self.hendlers[listener2] = ref_1
			
		}, withCancel: nil)
	}
	
	
	
	/// фикс бага, когда фото профиля неправильно загружается у пользователей (image flickering)
	/// попытка перегрузить таблицу
	private func attemptReloadofTable(){
		timer?.invalidate()
		labelNoMessages?.text = "Загрузка..."
		timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.delayedRelodTable), userInfo: nil, repeats: false)
	}
	
	/// (без этого таблица перезагружается десятки раз)
	@objc private func delayedRelodTable(){
		messages = Array(self.messagesDict.values)
		
		if messages.isEmpty{
			labelNoMessages?.text = "Нет сообщений"
		}
		else {
			labelNoMessages?.removeFromSuperview()
			labelNoMessages = nil
		}
		
		messages.sort(by: {
			(message1, message2) -> Bool in
			return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
		})
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	
	
	
	
	private func drawNoMessages(){
		
		if !messages.isEmpty {
			return
		}
		
		labelNoMessages?.removeFromSuperview()
		labelNoMessages = nil
		
		labelNoMessages = {
			let label = UILabel()
			label.text = "Загрузка..."
			label.backgroundColor = .clear
			label.textColor = .lightGray
			label.font = UIFont.boldSystemFont(ofSize: 25)
			label.textAlignment = .center
			label.translatesAutoresizingMaskIntoConstraints = false
			return label
		}()
		attemptReloadofTable()
		
		guard let labelNoMessages = labelNoMessages else { return }
		
		view.addSubview(labelNoMessages)
		
		labelNoMessages.topAnchor.constraint(equalTo: tableView.topAnchor, constant: -64).isActive = true
		labelNoMessages.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
		labelNoMessages.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive = true
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
	
	
	
	/// Проверка аутентиф. юзера и первое заполнение данных юзера
	public func fetchUserAndSetupNavbarTitle(){
		
		guard let uid = Auth.auth().currentUser?.uid else {	return } // проверка если user = nil
		self.uid = uid
		refUsers.child(uid).observeSingleEvent(of: .value) {
			(snapshot) in
			
			if let dictionary = snapshot.value as? [String:AnyObject] {
			
				// для отрисовки навбара нужны данные по юзеру
				let user = User()
				user.setValuesForKeys(dictionary)
				self.owner = user
				self.setupNavbarWithUser(user: user)
			}
		}
	}
	
	
	
	/// Отрисовка навбара с картинкой (этот метод может дергаться при регистрации из LoginController)
	public func setupNavbarWithUser(user: User){
		
		if owner == nil {
			owner = user
		}

		// чистим данные, т.к. если перелогинится под другим юзером они остаются
		messages.removeAll()
		messagesDict.removeAll()
		tableView.reloadData()
		
		drawNoMessages()
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
		
		// удаляем слушателя собственных сообщений
		refUserMessages?.removeAllObservers()
		
		// удаляем слушателей сообщений каждого фигуранта диалога
		for (key, value) in hendlers {
			value.removeObserver(withHandle: key)
		}

		uid = nil
		
		messages.removeAll()
		messagesDict.removeAll()
		hendlers.removeAll()
		tableView.reloadData()
		
		senders.removeAll()
		
		owner = nil
		labelNoMessages?.removeFromSuperview()
		labelNoMessages = nil
		
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
		newMessContr.owner = owner
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
















