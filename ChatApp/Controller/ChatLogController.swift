//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 06.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase



class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
	
	public var user:User? {
		didSet{
			navigationItem.title = user?.name
			observeMessages()
		}
	}
	
	private lazy var inputTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Введите текст..."
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.delegate = self
		return tf
	}()
	
	
	private lazy var inputContainerView: UIView = {
		// контейнер + фон
		let containerView = UIView()
		containerView.backgroundColor = .white
		containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
		containerView.translatesAutoresizingMaskIntoConstraints = false
//		view.addSubview(containerView)
//		containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//		containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
//		containerViewBottomAnchor?.isActive = true
//		containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//		containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		// линия-сепаратор
		let sepLine = UIView()
		sepLine.backgroundColor = UIColor.lightGray
		sepLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 1)
		sepLine.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(sepLine)
		sepLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
		sepLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		sepLine.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		sepLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		
		// кнопка
		let sendButton = UIButton(type: .system) // .system - для того, чтоб у кнопки были состояния нажатая/отжатая
		sendButton.setTitle("Отправ.", for: UIControlState.normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.addTarget(self, action: #selector(onSendClick), for: UIControlEvents.touchUpInside)
		containerView.addSubview(sendButton)
		sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
		sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
		sendButton.layer.cornerRadius = 10
		
		// текстовое поле
		containerView.addSubview(self.inputTextField)
		self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
		self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
		self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
		
		return containerView
	}()
	
	
	private let cell_ID:String = "cell_ID"
	private var messages:[Message] = []
	private var containerViewBottomAnchor:NSLayoutConstraint?
	
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
		layout?.minimumLineSpacing = 12 // расстояние сверху и снизу ячеек (по дефолту = 12)
		
		collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0) // вставляем поля чтоб чат не соприкосался сверху и снизу
		collectionView?.alwaysBounceVertical = true
		collectionView?.backgroundColor = .white
		collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cell_ID)
		
		// поведение клавиатуры при скроллинге
		collectionView?.keyboardDismissMode = .interactive
		
//		setupInputComponents()
//
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	
	
	/// прицепляем "аксессуар" в виде вьюшки на клавиатуру
	override var inputAccessoryView: UIView? {
		get {
			return inputContainerView
		}
	}
	override var canBecomeFirstResponder: Bool {
		return true // без этого не отображается inputContainerView
	}
	
	
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self) // слушатели всегда нужно убирать, иначе будет утечка памяти и многократное срабатывание
	}
	
	
	
	/// переопеределяем констрайнты при каждом повороте экрана (на некоторых моделях телефонов если не сделать - будет залазить/вылазить справа весь контент скролвьюшки)
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		collectionView?.collectionViewLayout.invalidateLayout()
		collectionView?.reloadData()
	}
	
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_ID, for: indexPath) as! ChatMessageCell
		
		let message = messages[indexPath.item]
		cell.setupCell(linkToParent: self, message: message)
		
		return cell
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var hei:CGFloat = 80
		
		// получаем ожидаемую высоту
		if let text = messages[indexPath.item].text {
			hei = estimatedFrameForText(text: text).height + 20 + 10
		}
		return CGSize(width: UIScreen.main.bounds.width, height: hei)
		
	}
	
	
	
	
	
	
	
	/// подсчет ожидаемых размеров текстового поля
	public func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: UIScreen.main.bounds.width * 2/3, height: .infinity)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	

	
	
	
	private func observeMessages(){
		
		guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else { return }
		
		let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toID) // ссылка на список сообщений
		userMessagesRef.observe(.childAdded, with: {
			(snapshot) in
			
			let messagesRef = Database.database().reference().child("messages").child(snapshot.key) // ссылка на сами сообщения
			
			messagesRef.observeSingleEvent(of: .value, with: {
				(snapshot) in
				
				guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
					
				let message = Message()
				message.setValuesForKeys(dictionary)
				
				self.messages.append(message)
				
				// нужна ли сортировка????
				self.messages.sort(by: {
					(message1, message2) -> Bool in
					return (message1.timestamp?.intValue)! < (message2.timestamp?.intValue)!
				})
				
				DispatchQueue.main.async {
					self.collectionView?.reloadData()
					// прокручиваем скролл вниз
					self.collectionView?.scrollToLast()
				}
				
			}, withCancel: nil)
			
		}, withCancel: nil)
	}

	
	
	
	
	@objc private func onSendClick(){
		
		inputTextField.resignFirstResponder()
		
		if inputTextField.text == "" || inputTextField.text == " " { return }
		
		let ref = Database.database().reference().child("messages")
		// генерация псевдо-рандомных ключей сообщения
		let childRef = ref.childByAutoId()
		// https://chatapp-2222e.firebaseio.com/messages/-LQe7kjoAJkrVNzOjERM
		
		let toID = user!.id!
		let fromID = Auth.auth().currentUser!.uid
		let timestamp:Int = Int(NSDate().timeIntervalSince1970)
		
		let values:[String:Any] = [
			"text"		:inputTextField.text!,
			"toID"		:toID,
			"fromID"	:fromID,
			"timestamp"	:timestamp
			]
		
		childRef.updateChildValues(values) {
			(error:Error?, ref:DatabaseReference) in
			if error != nil {
				print(error?.localizedDescription ?? "*")
				return
			}
			
			let messRef = Database.database().reference().child("user-messages")
			
			// создаем структуру цепочки сообщений ОТ определенного пользователя (тут будут лишь ID сообщений)
			let senderRef = messRef.child(fromID).child(toID)
			let messageID = childRef.key!
			senderRef.updateChildValues([messageID: 1])
			
			// создаем структуру цепочки сообщений ДЛЯ определенного пользователя (тут будут лишь ID сообщений)
			let recipientRef = messRef.child(toID).child(fromID)
			recipientRef.updateChildValues([messageID: 1])
		}
		inputTextField.text = nil
	}
	
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		onSendClick()
		return true
	}
	
	
	
	

	
	//	@objc private func keyboardWillShow(notif: Notification){
	//		if let keyboardFrame = (notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
	//			self.containerViewBottomAnchor?.constant = -keyboardFrame.height
	//		}
	//		// находим значение длительности анимации выезжания клавиатуры
	//		let keyboardDuration = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
	//
	//		// добавляем анимацию передвигания inputTextField (синхронно с выезжанием клавиатуры)
	//		UIView.animate(withDuration: keyboardDuration) {
	//			self.view.layoutIfNeeded()
	//		}
	//	}
	
	
	//	@objc private func keyboardWillHide(notif: Notification){
	//		containerViewBottomAnchor?.constant = 0
	//		let keyboardDuration = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
	//		UIView.animate(withDuration: keyboardDuration) {
	//			self.view.layoutIfNeeded()
	//		}
	//	}
	
	
	
	
	//	private func setupInputComponents(){
	//
	//		// контейнер + фон
	//		let containerView = UIView()
	//		containerView.backgroundColor = .white
	//		containerView.translatesAutoresizingMaskIntoConstraints = false
	//		view.addSubview(containerView)
	//		containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
	//
	//		containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
	//		containerViewBottomAnchor?.isActive = true
	//
	//		containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
	//		containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
	//
	//		// линия-сепаратор
	//		let sepLine = UIView()
	//		sepLine.backgroundColor = UIColor.lightGray
	//		sepLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 1)
	//		sepLine.translatesAutoresizingMaskIntoConstraints = false
	//		containerView.addSubview(sepLine)
	//		sepLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
	//		sepLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
	//		sepLine.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
	//		sepLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
	//
	//		// кнопка
	//		let sendButton = UIButton(type: .system) // .system - для того, чтоб у кнопки были состояния нажатая/отжатая
	//		sendButton.setTitle("Send", for: UIControlState.normal)
	//		sendButton.translatesAutoresizingMaskIntoConstraints = false
	//		sendButton.addTarget(self, action: #selector(onSendClick), for: UIControlEvents.touchUpInside)
	//		containerView.addSubview(sendButton)
	//		sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
	//		sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
	//		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
	//		sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
	//		sendButton.layer.cornerRadius = 10
	//
	//		// текстовое поле
	//		containerView.addSubview(inputTextField)
	//		inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
	//		inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
	//		inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
	//		inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
	//	}
	
	
	
}



extension UICollectionView {
	
	func scrollToLast() {
		guard numberOfSections > 0 else { return }
		
		let lastSection = numberOfSections - 1
		
		guard numberOfItems(inSection: lastSection) > 0 else { return }
		
		let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
		
		scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
	}
}

















