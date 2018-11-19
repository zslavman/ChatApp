//
//  ChatInputView.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 18.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class ChatInputView: UIView, UITextFieldDelegate {
	
	private let sendButton = UIButton(type: .system) // .system - для того, чтоб у кнопки были состояния нажатая/отжатая
	public var chatLogController:ChatLogController? {
		didSet{
			sendButton.addTarget(chatLogController, action: #selector(ChatLogController.onSendClick), for: UIControlEvents.touchUpInside)
			
			// uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onUploadClick)))
			uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.onUploadClick)))
		}
	}
	
	public lazy var inputTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Введите текст..."
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.delegate = self
		return tf
	}()
	
	
	private let uploadImageView: UIImageView = {
		let uv = UIImageView()
		uv.image = UIImage(named: "upload_image_icon")
		uv.isUserInteractionEnabled = true
		uv.translatesAutoresizingMaskIntoConstraints = false
		return uv
	}()
	
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		
		// картинка слева (отправить фото)
		addSubview(uploadImageView)
		uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
		uploadImageView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
		uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true // эпл рекомендует размер 44
		uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		// линия-сепаратор
		let sepLine = UIView()
		sepLine.backgroundColor = UIColor.lightGray
		sepLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 1)
		sepLine.translatesAutoresizingMaskIntoConstraints = false
		addSubview(sepLine)
		sepLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
		sepLine.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		sepLine.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		sepLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		

		// кнопка
		sendButton.setTitle("Отправ.", for: UIControlState.normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.layer.cornerRadius = 10
		addSubview(sendButton)
		sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
		sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
		
		// текстовое поле
		addSubview(inputTextField)
		inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 10).isActive = true
		inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
		inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
	}
	
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		chatLogController?.onSendClick()
		return true
	}
	
	
	
	
	
	
	
	
	
	
	
	 
	
}
