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
import NPTableAnimator


class MessagesController: UITableViewController {

	public var owner: ChatUser!
	internal var uid: String!
	public static var shared: MessagesController!
	
	internal let cell_id = "cell_id"
	private var timer: Timer? 							// таймер-задержка перезагрузки таблицы
	
	internal var refUsers 		= Database.database().reference().child("users")
	private var refMessages 	= Database.database().reference().child("messages")
	private var refUserMessages: DatabaseReference! 		// ссылка, у которой вконце будет приписан изменяющийся uid
	
	
	internal let refUserMessages_original = Database.database().reference().child("user-messages")// начало ссылки для refUserMessages
	internal var labelNoMessages: UILabel? // placeholder for emty table
	
	private var hendlers = [UInt: DatabaseReference]() 	// для правильного диспоза слушателей базы
	internal var profileImageView: UIImageView!
	public var senders = [ChatUser]() 					// данные юзеров с которым есть чаты
	
	private var audioPlayer = AVAudioPlayer()
	private var allowIncomingSound: Bool = false // флаг, разрешающий восп. звук когда приходит сообщение
	public var goToChatWithID: String?			// ID собеседника, с которым перешли в чат
	public var savedIndexPath: IndexPath?		// тут будет путь к ячейке по которой кликнули
	
	public var isOnline: Bool = true
	
	// массив диалогов (здесь проходит вся математика манипуляций, во вьюшки он не идет)
	// после завершения маневров с данными всегда необходимо вызвать reloadTable()
	// но, если время в ячейке не придет новое - то и никакиие другие параметры не обновятся!!
	// т.е. для обновления статуса непрочтенности необходимо записать новый статус в оба массива
	public var messages: [Message] = []
	public var messages_copy: [Message] = [] 	 // массив для учёта кол-ва соообщений в фоне
	internal var currentList: [MySection]! = nil // то что отображается после манипуляций с messages (для вьюшек)
	internal let animator = TableAnimator<MySection>()
	


	override func viewDidLoad() {
		super.viewDidLoad()
		MessagesController.shared = self
		currentList = [MySection(cells: messages)]
		navigationController?.view.backgroundColor = UIConfig.mainThemeColor
		chekIfUserLoggedIn()
		tableView.register(UserCell.self, forCellReuseIdentifier: cell_id)
		tableView.separatorColor = UIConfig.mainThemeColor.withAlphaComponent(0.5)
		
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
		
		for (element) in hendlers {
			if element.value.description() == onlineListener.description() || element.value.description() == removeMessListener.description(){
				element.value.removeObserver(withHandle: element.key)
				hendlers.removeValue(forKey: element.key)
			}
		}
		// удаляем из источника таблицы и самой таблицы
		// один из методов обновления таблицы, но он не безопасный
		messages.remove(at: indexPath.row)
		if messages.isEmpty {
			labelNoMessages?.text = dict[32]![LANG]
		}
		//tableView.deleteRows(at: [indexPath], with: .right)
		reloadTable()
	}
		
	

	// MARK: получение диалогов
	/// получаем сообщения с сервера, добавляем слушатели на новые
	private func fetchDialogs() {
		guard let uid = Auth.auth().currentUser?.uid else { return } // если взять uid из self то при регистрации тут выйдет
		if self.uid == nil {
			self.uid = uid
		}
		var dialogsStartCount: UInt = 0 // общее кол-во диалогов
		var dialogsLoadedCount: UInt = 0
		refUserMessages = refUserMessages_original.child(uid)

		// проверяем сколько (диалогов) имеет owner
		refUserMessages.observeSingleEvent(of: .value, with: {
			(snapshot) in
			// если вообще нет сообщений
			if !snapshot.hasChildren() {
				self.labelNoMessages?.text = dict[32]![LANG] // нет сообощений
				self.allowIncomingSound = true
			}
			dialogsStartCount = snapshot.childrenCount
			
			
			// получаем ID юзеров, которые писали owner'у (цикл из диалогов)
			let newMesListener = self.refUserMessages.observe(.childAdded, with: {
				(snapshot) in

				dialogsLoadedCount += 1
				let userID = snapshot.key
				let ref_DialogforEachOtherUser = self.refUserMessages_original.child(uid).child(userID)
				
				//***********
				// если это последний скачиваемый диалогер, смотрим сколько в диалоге сообщений
				// и только после послднего полученного включаем звук на приход сообщ.
				var maxCount: UInt = 0
				var currentCount: UInt = 0
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
								self.currentList[0].cells.append(message)
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
			self.hendlers[newMesListener] = self.refUserMessages // фикс -> вышел, зарегился, пишешь кому-то и ошибка
		})
	}
	
	
	/// добавляем слушатель, на всех фигурантов переписки, на предмет онлайн/оффлайн
	private func addOnlineListener(ref: DatabaseReference) {
		let listener = ref.observe(.value, with: {
			(snapshot) in
			guard self.allowIncomingSound else { return }
			// в массиве sender ищем юзера который пришел в snapshot'e
			if let dict = snapshot.value as? [String:AnyObject] {
				
				let id_WhoChangedStatus = dict["id"] as! String
				let newStatus 			= dict["isOnline"] as! Bool
				
				for (_, value) in self.senders.enumerated() {
					
					if value.id! == self.goToChatWithID {
						// send notification for ChatController "userChangeStatus"
						let dataDict = ["dStatus" : newStatus]
						NotificationCenter.default.post(name: .dialogerDidChangeStatus, object: nil, userInfo: dataDict)
					}
					
					if id_WhoChangedStatus == value.id {
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
	
	
	
	// проверка кол-ва непрочтенных сообщений (вызывается при каждом приходе нового сообщ.)
	private func checkUnread(msg:Message) {
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
						if self.goToChatWithID != msg.chatPartnerID(){ // добавляем непрочтенные только если не общаемся с диалогером
							self.messages[index].unreadCount = snapshot.childrenCount
						}
						flag = true
						break
					}
				}
				if !flag {
					msg.unreadCount = snapshot.childrenCount
				}
				// добавляем непрочтенные только если не общаемся с диалогером
				if snapshot.childrenCount == 1 && self.goToChatWithID != msg.chatPartnerID() {
					self.addBageValue(val: 1)
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
	private func countUnreadMessages() {
		// получаем весь словарь непрочтенных
		let unreadRef = Database.database().reference().child("unread-messages-foreach").child(uid)
		var count:Int = 0

		unreadRef.observeSingleEvent(of: .value) {
			(snapshot) in

			if let dictionary = snapshot.value as? [String:AnyObject] {
				// устанавливаем в каждого диалогера кол-во непрочтенных
				for index in self.messages.indices{
					let keyName = self.messages[index].chatPartnerID()!
					if dictionary.keys.contains(keyName){
						self.messages[index].unreadCount = UInt(dictionary[keyName]!.count)
						count += 1
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
			self.addBageValue(val: count)
			self.firstReloadTable()
		}
	}
	
	
	// плюсуем счетчик ярлыка текущей вкладки
	internal func addBageValue(val: Int){
		guard val != 0 else { return }
		let thisTabItem = tabBarController?.tabBar.items!.first
		var currentCount:Int = 0
		
		for mes in messages {
			if mes.unreadCount != nil && mes.unreadCount! > 0 {
				currentCount += 1
			}
		}
		if val < 0 {
			currentCount += val
		}
		if currentCount <= 0 {
			thisTabItem?.badgeValue = nil
			UIApplication.shared.applicationIconBadgeNumber = 0
		}
		else {
			thisTabItem?.badgeValue = String(currentCount)
			UIApplication.shared.applicationIconBadgeNumber = currentCount
		}
	}
	
	
	public func countUnreadInBackground(from: String) {
		let newMessage = Message(dictionary: [
			"fromID"		: from,
			"toID"			: owner.id!,
			"timestamp"		: 123456,
			"unreadCount"	: 1
		])
		var uniqueDialog: Bool = true // if this is new dialog
		
		if messages_copy.isEmpty {
			messages_copy = messages
		}
		for index in messages_copy.indices {
			// если написавший юзер уже есть в диалогах
			if messages_copy[index].chatPartnerID() == from {
				if messages_copy[index].unreadCount != nil && messages_copy[index].unreadCount! > 0 {
					messages_copy[index].unreadCount! += 1
				}
				else {
					messages_copy[index].unreadCount = 1
				}
				uniqueDialog = false
			}
		}
		if uniqueDialog {
			messages_copy.append(newMessage)
		}
		var count = 0
		for mes in messages_copy {
			if mes.unreadCount != nil && mes.unreadCount! > 0 {
				count += 1
			}
		}
		if count > 0 {
			UIApplication.shared.applicationIconBadgeNumber = count
		}
	}
	
	

	/// первая перезагрузка таблицы и данных
	private func firstReloadTable() {
		allowIncomingSound = true
		if messages.isEmpty {
			labelNoMessages?.text = dict[32]![LANG] // Нет сообщений
		}
		currentList[0].cells.sort(by: {
			(message1, message2) -> Bool in
			return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
		})
		messages.sort(by: {
			(message1, message2) -> Bool in
			return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
		})
		DispatchQueue.main.async {
			self.tableView.reloadData()
			// Calculations.animateTable(tableView: self.tableView, duration: 0.5)
			SUtils.animateTableWithSections(tableView: self.tableView)
		}
		createBarItem()
	}
	
	
	internal func reloadTable() {
		messages.sort(by: {
			(message1, message2) -> Bool in
			return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
		})
		// в этот момент, самые свежие изменения есть только в messages
		// с свою очередь, currentList еще этих изменений не имеет
		let toList:[MySection] = [MySection(cells: messages)]
		
		tableView.apply(owner			: self,
						newList			: toList,
						animator		: animator,
						animated		: true,
						options			: [.cancelPreviousAddedOperations, .withoutAnimationForEmptyTable],
						getCurrentListBlock: { $0.currentList },
						setNewListBlock	: { $0.currentList = $1 },
						rowAnimation	: .fade,
						completion		: nil,
						error			: nil)
		print("перезагружаем таблицу")
	}
	

	private func chekIfUserLoggedIn(){
		// выходим, если не залогинены
		if Auth.auth().currentUser?.uid == nil{
			// аля задержка, для устранения Unbalanced calls to begin/end appearance transitions for <UINavigationController: 0x7f...
			dispose()
			perform(#selector(onLogout), with: nil, afterDelay: 0)
		}
		// автологинка
		else {
			Notifications.shared.requestAuthorisation()
			fetchUserAndSetupNavbarTitle()
		}
	}
	
	
	/// Проверка аутентиф. юзера и первое заполнение данных юзера
	public func fetchUserAndSetupNavbarTitle() {
		guard let uid = Auth.auth().currentUser?.uid else {	return } // проверка если user = nil
		self.uid = uid
		
		refUsers.child(uid).observeSingleEvent(of: .value) {
			(snapshot) in
			if let dictionary = snapshot.value as? [String:AnyObject] {
				// для отрисовки навбара нужны данные по юзеру
				let user = ChatUser()
				user.setValuesForKeys(dictionary)
				self.owner = user
				self.setupNavbarWithUser(user: user)
			}
		}
	}
	

	public func setupNavbarWithUser(user: ChatUser) {
		if owner == nil {
			owner = user
		}
		// устанавливаем индикацию онлайн
		APIServices.setUserStatus(true)
		fetchDialogs()
		drawAvaAndName()
	}
	
	
	private func drawAvaAndName() {
		// фотка
		profileImageView = UIImageView()
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.layer.cornerRadius = 18
		profileImageView.clipsToBounds = true
		profileImageView.frame.size = CGSize(width: 32, height: 32) // for iOS 10
		profileImageView.image = UIImage(named: "default_profile_image")
		
		if let profileImageUrl = owner.profileImageUrl {
			profileImageView.loadImageUsingCache(urlString: profileImageUrl, isAva: true, completionHandler: nil)
		}
		NSLayoutConstraint.activate([
			profileImageView.widthAnchor.constraint(equalToConstant: 32),
			profileImageView.heightAnchor.constraint(equalToConstant: 32)
		])
		profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPhotoClick(sender:))))
		profileImageView.isUserInteractionEnabled = true
		
		let nameLabel = UILabel()
		nameLabel.text = owner.name
		nameLabel.textColor = UIColor.white
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.minimumScaleFactor = 0.9
		nameLabel.frame.size = CGSize(width: 500, height: 50) // for iOS 10
		nameLabel.sizeToFit()
		
		let stackView = UIStackView(arrangedSubviews: [profileImageView, nameLabel])
		stackView.axis = .horizontal
		stackView.spacing = 6
		stackView.backgroundColor = UIColor.orange
		stackView.frame.size = CGSize(width: profileImageView.frame.width + nameLabel.frame.width, height: max(nameLabel.frame.height, profileImageView.frame.height))
		
		navigationItem.titleView = stackView
	}
	
	

	public func dispose() {
		// записуем на сервер состояние "offline"
		if (uid != nil) {
			APIServices.setUserStatus(false)
		}
		// удаляем слушателя собственных сообщений
		refUserMessages?.removeAllObservers()
		// удаляем слушателей сообщений каждого фигуранта диалога
		for (key, ref) in hendlers {
			ref.removeObserver(withHandle: key)
		}
		uid = nil
		
		messages.removeAll()
		messages_copy.removeAll()
		currentList[0].cells.removeAll()
		hendlers.removeAll()
		tableView.reloadData()
		allowIncomingSound = false
		
		senders.removeAll()
		
		navigationItem.rightBarButtonItem = nil
		
		owner = nil
		labelNoMessages?.removeFromSuperview()
		labelNoMessages = nil
		
		// чистим ярлыки
		tabBarController?.tabBar.items!.first?.badgeValue = nil
		UIApplication.shared.applicationIconBadgeNumber = 0
		
		APIServices.removeToken()
		UIApplication.shared.unregisterForRemoteNotifications()
	}
	
	
	
	@objc private func onLogout(){
		let loginController = LoginController(collectionViewLayout: UICollectionViewFlowLayout())
		// фикс бага когда выходишь и регишся а тайтл не меняется
		loginController.messagesController = self
		
		present(loginController, animated: true, completion: nil)
	}
	
	
	// NOT USED
	@objc private func onNewMessageClick(){
		let findUserContr = FindUserForChatController()
		let navContr = UINavigationController(rootViewController: findUserContr)
		present(navContr, animated: true, completion: nil)
		// navigationController?.pushViewController(findUserContr, animated: true)
	}
	
	
	@objc public func goToChatWith(user: ChatUser){
		// запоминаем юзера, с которым перешли в чат (для блокировки проигрыв звуков при сообщениях от него)
		// about sound - no longer need
		goToChatWithID = user.id!
		let chatLogController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
		chatLogController.user = user
		chatLogController.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(chatLogController, animated: true)
	}
	
	
	private func playSoundFile(_ soundName:String) {
		if !allowIncomingSound { return }
		if !UserDefFlags.sound_mess { return }
		//audioPlayer.play()
		if UserDefFlags.vibro_mess{
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
		}
	}
}



// смена аватарки
extension MessagesController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	@objc internal func onPhotoClick(sender: UITapGestureRecognizer) {
		AppDelegate.waitScreen.show()
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true
		
		present(picker, animated: true, completion: {
			AppDelegate.waitScreen.hideNow()
		})
	}
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		// Local variable inserted by Swift 4.2 migrator.
		let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
		var selectedImage:UIImage?
		
		if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage{
			selectedImage = editedImage
		}
		else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
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
		if let uploadData = imag.jpegData(compressionQuality: 0.5){
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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
