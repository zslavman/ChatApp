//
//  ViewController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class MessagesController: UITableViewController {

	
	internal var owner:User!
	internal var uid:String!
	public var messages:[Message] = [] 				// массив диалогов
	internal let cell_id = "cell_id"
	private var timer:Timer? 							// таймер-задержка перезагрузки таблицы
	
	internal var refUsers 		= Database.database().reference().child("users")
	private var refMessages 	= Database.database().reference().child("messages")
	private var refUserMessages:DatabaseReference! 		// ссылка, у которой вконце будет приписан изменяющийся uid
	
	
	internal let refUserMessages_original = Database.database().reference().child("user-messages")// начало ссылки для refUserMessages
	private var labelNoMessages:UILabel?
	
	private var hendlers = [UInt:DatabaseReference]() 	// для правильного диспоза слушателей базы
	internal var profileImageView:UIImageView!
	internal var senders = [User]() 						// данные юзеров с которым есть чаты
	
	enum status:String {
		case loading 	= "Загрузка..."
		case nomessages = "Нет сообщений"
	}

	private var audioPlayer = AVAudioPlayer()
	private var allowIncomingSound:Bool = false // флаг, разрешающий восп. звук когда приходит сообщение
	internal var goToChatWithID:String?			// ID собеседника, с которым перешли в чат
	public var savedIndexPath:IndexPath?		// тут будет путь к ячейке по которой кликнули
	
	
	
	
	

	override func viewDidLoad() {
		super.viewDidLoad()

		let bttnImage1 = UIImage(named: "bttn_logout")
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: bttnImage1, style: .plain, target: self, action: #selector(onLogout))
		navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.1450980392, green: 0.5294117647, blue: 1, alpha: 1)
		
		let bttnImage2 = UIImage(named: "bttn_find_user")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: bttnImage2, style: .plain, target: self, action: #selector(onNewMessageClick))
		navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.1450980392, green: 0.5294117647, blue: 1, alpha: 1)
		
		chekIfUserLoggedIn()
		
		tableView.register(UserCell.self, forCellReuseIdentifier: cell_id)
		

		let url = Bundle.main.url(forResource: "pipk", withExtension: "mp3")!
		do { audioPlayer = try AVAudioPlayer(contentsOf: url) }
		catch { print("error loading file") }
	}
	
	
	
	

	
	
	
	
	/// убираем собеседника и само сообщение отовсюду
	internal func removeDialog(collocutorID: String, indexPath:IndexPath){

		// находим собеседника в массиве senders и убираем из массива
		senders = senders.filter({$0.id == collocutorID})
		
		// нужно убрать слушатель онлайна для этого собеседника
		let onlineListener = refUsers.child(collocutorID)
		let removeMessListener = refUserMessages_original.child(uid).child(collocutorID)
		
		for (element) in hendlers{
			if element.value.description() == onlineListener.description() || element.value.description() == removeMessListener.description(){
				element.value.removeObserver(withHandle: element.key)
				hendlers.removeValue(forKey: element.key)
			}
		}
		
		// удаляем из источника таблицы и самой таблицы
		// один из методов обновления таблицы, но он не безопасный
		messages.remove(at: indexPath.row)
		
		if messages.isEmpty {
			drawLoading(text: status.nomessages.rawValue)
		}
		tableView.deleteRows(at: [indexPath], with: .right)
	}
		
	
	
	
	
	// MARK: получение диалогов
	/// получаем сообщения с сервера, добавляем слушатели на новые
	private func fetchDialogs(){
		
		guard let uid = Auth.auth().currentUser?.uid else { return } // если взять uid из self то при регистрации тут выйдет
		
		var dialogsStartCount:UInt = 0 // общее кол-во диалогов
		var dialogsLoadedCount:UInt = 0
		refUserMessages = refUserMessages_original.child(uid)
		
		
		// проверяем сколько (диалогов) имеет owner
		refUserMessages.observeSingleEvent(of: .value, with: {
			(snapshot) in
			// если вообще нет сообщений
			if !snapshot.hasChildren() {
				self.labelNoMessages?.text = status.nomessages.rawValue
				self.allowIncomingSound = true
			}
			dialogsStartCount = snapshot.childrenCount
			
			
			// получаем ID юзеров, которые писали owner'у (цикл из диалогов)
			self.refUserMessages.observe(.childAdded, with: {
				(snapshot) in

				dialogsLoadedCount += 1
				let userID = snapshot.key
				let ref_DialogforEachOtherUser = self.refUserMessages_original.child(self.uid).child(userID)
				
				//***********
				// если это последний скачиваемый диалогер, смотрим сколько в диалоге сообщений
				// и только после послднего полученного включаем звук на приход сообщ.
				var maxCount:UInt = 0
				var currentCount:UInt = 0
				if dialogsLoadedCount == dialogsStartCount {
					maxCount = min(1, snapshot.childrenCount)
				}
				//***********


				// получаем ID сообщения внутри диалога (цикл из сообщений)
				let listener1 = ref_DialogforEachOtherUser.queryLimited(toLast: 1).observe(.childAdded, with: {
					(snapshot) in
					let messageID = snapshot.key
					
					
					// получаем каждое сообщение
					self.refMessages.child(messageID).observeSingleEvent(of: .value, with: {
						(snapshot) in
						
						currentCount += 1
						
						if let dictionary = snapshot.value as? [String:AnyObject] {
							let message = Message(dictionary: dictionary) // message.setValuesForKeys(dictionary)
							
							if !self.allowIncomingSound {
								self.messages.append(message)
							}
							
							// если это сообщение отправил owner или собеседник с которым сейчас чат, звук не проигрываем
							let fromWho = (dictionary["fromID"] as? String)!
							if fromWho != self.uid {
								if fromWho != self.goToChatWithID && fromWho != self.goToChatWithID{
									self.playSoundFile("pipk")
								}
							}
							// запуск обновления таблицы первый раз
							if (dialogsLoadedCount == dialogsStartCount && currentCount == maxCount){
								/* 1) проверить каждый диалог на наличие непрочтенных сообщ
								 2) Перезагрузить таблицу
								 3) Слушать изменения в диалогах
										а) запрос на кол-во непрочтенных
										б) перетасовка таблицы с перезагрузкой */
								self.countUnreadMessages()
							}
							// последюущие разы
							else if (self.allowIncomingSound && currentCount > maxCount) {
								self.checkUnread(msg: message)
							}
						}
					})
				})
				
				// добавляем слушатель, на всех фигурантов переписки, на предмет онлайн/оффлайн
				let ref_forOnlineListener = Database.database().reference().child("users").child(userID)
				self.addOnlineListener(ref: ref_forOnlineListener)
				
				// записываем слушателя (на изменение диалога) и ссылки в словарь (для дальнейшего диспоза)
				self.hendlers[listener1] = ref_DialogforEachOtherUser
			})
		})
	}
	
	
	
	
	
	
	/// добавляем слушатель, на всех фигурантов переписки, на предмет онлайн/оффлайн
	private func addOnlineListener(ref:DatabaseReference){
		
		let listener = ref.observe(.value, with: {
			(snapshot) in
			
			guard self.allowIncomingSound else { return }
			
			// в массиве sender ищем юзера который пришел в snapshot'e
			if let dict = snapshot.value as? [String:AnyObject] {
				
				let id_WhoChangedStatus = dict["id"] as! String
				let newStatus 			= dict["isOnline"] as! Bool
				
				for (_, value) in self.senders.enumerated() {
					if id_WhoChangedStatus == value.id{
						value.isOnline = newStatus
						
						// чтоб не перегружать всю таблицу
						let visible = self.tableView.visibleCells as! [UserCell]
						visible.forEach({
							(cell) in
							if cell.userID == id_WhoChangedStatus{
								cell.onlinePoint.backgroundColor = newStatus ? UserCell.onLineColor : UserCell.offLineColor
							}
						})
						break
					}
				}
			}
		})
		// записываем слушателей и ссылки в словарь (для дальнейшего диспоза)
		hendlers[listener] = ref
	}
	
	
	
	
	

	private func reloadTable(){
		print("перегрузили таблицу")
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}

	
	
	// проверка кол-ва непрочтенных сообщений (вызывается при каждом приходе нового сообщ.)
	private func checkUnread(msg:Message){
		
		if msg.fromID == uid {
			moveDialogs(newMessage: msg)
			return
		}
		
		let unreadRef = Database.database().reference().child("unread-messages-foreach").child(uid).child(msg.fromID!)

		unreadRef.observeSingleEvent(of: .value) {
			(snapshot) in
			var flag:Bool = false
			if snapshot.exists() && snapshot.childrenCount > 0 {
				for index in self.messages.indices{
					if self.messages[index].chatPartnerID()! == msg.fromID! {
						self.messages[index].unreadCount = snapshot.childrenCount
						flag = true
						break
					}
				}
				if !flag {
					msg.unreadCount = snapshot.childrenCount
				}
				self.moveDialogs(newMessage: msg)
			}
		}
	}
	
	
	
	
	/// обновление порядка следования диалогов
	private func moveDialogs(newMessage:Message){
		
		// если диалогер уже есть в списке - удаляем его
		for index in messages.indices {
			if messages[index].chatPartnerID()! == newMessage.chatPartnerID()!{
				newMessage.unreadCount = messages[index].unreadCount // перекидываем непрочтенные, если есть
				messages.remove(at: index)
				break
			}
		}
		// вставляем новое сообщ. в начало
		messages.insert(newMessage, at: 0)
		
		reloadTable()
	}
	
	
	
	/// калькуляция непрочитанных сообщений каждого диалогера (запускается 1 раз при загрузке, когда получили все диалоги)
	private func countUnreadMessages(){

		// получаем весь словарь непрочтенных
		let unreadRef = Database.database().reference().child("unread-messages-foreach").child(uid)

		unreadRef.observeSingleEvent(of: .value) {
			(snapshot) in

			if let dictionary = snapshot.value as? [String:AnyObject] {
				// устанавливаем в каждого диалогера кол-во непрочтенных
				for index in self.messages.indices{
					let keyName = self.messages[index].chatPartnerID()!
					if dictionary.keys.contains(keyName){
						self.messages[index].unreadCount = UInt(dictionary[keyName]!.count)
					}
				}
			}
			else {
				self.messages = self.messages.map({
					(mes) -> Message in
					mes.unreadCount = nil
					return mes
				})
			}
			self.firstReloadTable()
		}
	}
	
	

	
	
	
	/// первая перезагрузка таблицы и данных
	private func firstReloadTable(){

		allowIncomingSound = true
		
		if messages.isEmpty{
			labelNoMessages?.text = status.nomessages.rawValue
		}
		else {
			labelNoMessages?.removeFromSuperview()
			labelNoMessages = nil
		}
		
		messages.sort(by: {
			(message1, message2) -> Bool in
			return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
		})
		
		reloadTable()
	}
	
	

	
	
	
	
	/// рисует лейблу с надписью Загрузка/Нет сообщений
	private func drawLoading(text:String = status.loading.rawValue){
		
		if !messages.isEmpty {
			return
		}
		
		labelNoMessages?.removeFromSuperview()
		labelNoMessages = nil
		
		labelNoMessages = {
			let label = UILabel()
			label.text = text
			label.backgroundColor = .clear
			label.textColor = .lightGray
			label.font = UIFont.boldSystemFont(ofSize: 25)
			label.textAlignment = .center
			label.translatesAutoresizingMaskIntoConstraints = false
			return label
		}()
		
		guard let labelNoMessages = labelNoMessages else { return }
		
		view.addSubview(labelNoMessages)
		
		labelNoMessages.topAnchor.constraint(equalTo: tableView.topAnchor, constant: -64).isActive = true
		labelNoMessages.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
		labelNoMessages.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive = true
	}
	
	
	
	private func chekIfUserLoggedIn(){
		// выходим, если не залогинены
		if Auth.auth().currentUser?.uid == nil{
			// аля задержка, для устранения Unbalanced calls to begin/end appearance transitions for <UINavigationController: 0x7f...
			perform(#selector(onLogout), with: nil, afterDelay: 0)
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
		
		// устанавливаем индикацию онлайн
		OnlineService.setUserStatus(status: true)

		drawLoading()
		fetchDialogs()
		
		// контейнер
		let titleView = UIView()
		titleView.frame = CGRect(x: 0, y: 0, width: 160, height: 40)
		
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
	


	

	
	@objc private func onLogout(){
		
		// записуем на сервер состояние "offline"
		if (uid != nil){
			OnlineService.setUserStatus(status: false)
		}
		
		// удаляем слушателя собственных сообщений
		refUserMessages?.removeAllObservers()
		
		// удаляем слушателей сообщений каждого фигуранта диалога
		for (key, ref) in hendlers {
			ref.removeObserver(withHandle: key)
		}

		uid = nil
		
		messages.removeAll()
		hendlers.removeAll()
		tableView.reloadData()
		allowIncomingSound = false
		
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

		let loginController = LoginController(collectionViewLayout: UICollectionViewFlowLayout())

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
		
		// запоминаем юзера, с которым перешли в чат (для блокировки проигрыв звуков при сообщениях от него)
		goToChatWithID = user.id!
		
		let chatLogController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.user = user
		navigationController?.pushViewController(chatLogController, animated: true)
	}
	
	
	
	private func playSoundFile(_ soundName:String) {
		
		if !allowIncomingSound { return }
		audioPlayer.play()
		
		//		let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")!
		//
		//		do {
		//			let sound = try AVAudioPlayer(contentsOf: url)
		//			audioPlayer = sound
		//			sound.numberOfLoops = 0
		//			sound.prepareToPlay()
		//			sound.play()
		//		}
		//		catch {
		//			print("error loading file")
		//		}
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
	
	
	
	
	

	
	
	
	/// фикс бага, когда фото профиля неправильно загружается у пользователей (image flickering)
	/// попытка перегрузить таблицу
	/// [НЕ ИСПОЛЬЗУЕТСЯ, т.к. нашел более рациональное решение]
//	private func attemptReloadofTable(){
//		timer?.invalidate()
//		timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.firstReloadTable), userInfo: nil, repeats: false)
//	}
	
}
















