//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 06.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


class ChatLogController: UICollectionViewController, UITextFieldDelegate {
	
	public var user:User? {
		didSet{
			navigationItem.title = user?.name
		}
	}
	
	private lazy var inputTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Enter message..."
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.delegate = self
		return tf
	}()
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView?.backgroundColor = .white
		
		setupInputComponents()
		
	}
	
	
	
	
	
	
	private func setupInputComponents(){
		
		// контейнер + фон
		let containerView = UIView()
//		containerView.backgroundColor = .red
		containerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(containerView)
		containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
		containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		// линия-сепаратор
		let sepLine = UIView()
		sepLine.backgroundColor = #colorLiteral(red: 0.9117823243, green: 0.9118037224, blue: 0.9117922187, alpha: 1)
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
		print(childRef)
		
		let toID = user!.id!
		let fromID = Auth.auth().currentUser?.uid
		let timestamp:Int = Int(NSDate().timeIntervalSince1970)
		
		let values:[String:Any] = [
			"text"		:inputTextField.text!,
			"toID"		:toID,
			"fromID"	:fromID!,
			"timestamp"	:timestamp
			]
		childRef.updateChildValues(values)
		
		inputTextField.text = nil
	}
	
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		onSendClick()
		return true
	}
	
	
	
}





















