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
		tf.placeholder = "Enter message..."
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.delegate = self
		return tf
	}()
	
	private let cell_ID:String = "cell_ID"
	private var messages:[Message] = []
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView?.alwaysBounceVertical = true
		collectionView?.backgroundColor = .white
		collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cell_ID)
		
		setupInputComponents()
	}
	
	
	
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_ID, for: indexPath) as! ChatMessageCell
		
		cell.textView.text = messages[indexPath.row].text
		
		// изменим ширину фона сообщения
		cell.bubbleWidthAnchor?.constant = 50
		
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var hei:CGFloat = 80
		
		// получаем ожидаемоую высоту
		if let text = messages[indexPath.item].text {
			hei = estimatedFrameForText(text: text).height + 20
		}
		
		return CGSize(width: view.frame.width, height: hei)
	}
	
	
	
	
	
	private func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: 200, height: 1000)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	
	
	
	
	
	private func observeMessages(){
		
		guard let uid = Auth.auth().currentUser?.uid else { return }
		let userMessagesRef = Database.database().reference().child("user-messages").child(uid) // ссылка на список сообщений
		userMessagesRef.observe(.childAdded, with: {
			(snapshot) in
			
			let messagesRef = Database.database().reference().child("messages").child(snapshot.key) // ссылка на сами сообщения
			
			messagesRef.observeSingleEvent(of: .value, with: {
				(snapshot) in
				
				guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
					
				let message = Message()
				message.setValuesForKeys(dictionary)
				
				// т.к. мы получили все сообщения кому юзер отправлял, и кто ему отпралял, то фильтруем
				if message.checkPartnerID() == self.user?.id{
					self.messages.append(message)
					
					self.messages.sort(by: {
						(message1, message2) -> Bool in
						return (message1.timestamp?.intValue)! < (message2.timestamp?.intValue)!
					})
					
					DispatchQueue.main.async {
						self.collectionView?.reloadData()
					}
				}
				
				// заполняем словарь и меняем массив
//				if let toID = message.toID {
//					self.messagesDict[toID] = message
//
//					self.messages = Array(self.messagesDict.values)
//					self.messages.sort(by: {
//						(message1, message2) -> Bool in
//						return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
//					})
//				}
				
				
				
				
			}, withCancel: nil)
			
		}, withCancel: nil)
	}
	
	
	
	
	private func setupInputComponents(){
		
		// контейнер + фон
		let containerView = UIView()
		containerView.backgroundColor = .white
		containerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(containerView)
		containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
		containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
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
		sendButton.setTitle("Send", for: UIControlState.normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.addTarget(self, action: #selector(onSendClick), for: UIControlEvents.touchUpInside)
		containerView.addSubview(sendButton)
		sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
		sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//		sendButton.backgroundColor = .green
		sendButton.layer.cornerRadius = 10
		
		// текстовое поле
		containerView.addSubview(inputTextField)
		inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
		inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
		inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
	}
	
	
	
	
	
	
	
	
	@objc private func onSendClick(){
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
			
			// создаем структуру цепочки сообщений ОТ определенного пользователя (тут будут лишь ID сообщений)
			let userMessagesRef = Database.database().reference().child("user-messages").child(fromID)
			let messageID = childRef.key!
			userMessagesRef.updateChildValues([messageID: 1])
			
			// создаем структуру цепочки сообщений ДЛЯ определенного пользователя (тут будут лишь ID сообщений)
			let recipientRef = Database.database().reference().child("user-messages").child(toID)
			recipientRef.updateChildValues([messageID: 1])
			
		}
		
		
		inputTextField.text = nil
	}
	
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		onSendClick()
		return true
	}
	
	
	
}





















