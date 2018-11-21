//
//  ChatInputView.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 18.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class ChatInputView: UIView, UITextViewDelegate {
	
	private let sendButton = UIButton(type: .system) // .system - для того, чтоб у кнопки были состояния нажатая/отжатая
	public var chatLogController:ChatLogController? {
		didSet{
//			sendButton.addTarget(chatLogController, action: #selector(chatLogController!.onSendClick), for: UIControlEvents.touchUpInside)
			sendButton.addTarget(self, action: #selector(onSend), for: UIControlEvents.touchUpInside)
			// uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onUploadClick)))
			uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.onUploadClick)))
		}
	}
	
	public lazy var inputTextField: UITextView = {
		let tf = UITextView()
		tf.text = placeholderStr
		tf.textColor = UIColor.lightGray
//		tf.backgroundColor = UIColor.red.withAlphaComponent(0.1)
		tf.backgroundColor = .clear
		tf.font = UIFont.systemFont(ofSize: 17)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.returnKeyType = .send // всего лишь вид кнопки "Enter"
		tf.delegate = self
		tf.isScrollEnabled = false
		return tf
	}()
	
	
	private let uploadImageView: UIImageView = {
		let uv = UIImageView()
		uv.image = UIImage(named: "upload_image_icon")
		uv.isUserInteractionEnabled = true
		uv.translatesAutoresizingMaskIntoConstraints = false
		return uv
	}()
	
	private var placeholderStr:String = "Введите текст..."

	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		backgroundColor = .white
		
		// картинка слева (отправить фото)
		addSubview(uploadImageView)
		uploadImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive 	= true
		uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive 		= true
		uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive 					= true // эпл рекомендует размер 44
		uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive 					= true
		
		// линия-сепаратор
		let sepLine = UIView()
		sepLine.backgroundColor = UIColor.lightGray
		sepLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 1)
		sepLine.translatesAutoresizingMaskIntoConstraints = false
		addSubview(sepLine)
		sepLine.topAnchor.constraint(equalTo: topAnchor).isActive 		= true
		sepLine.leftAnchor.constraint(equalTo: leftAnchor).isActive 	= true
		sepLine.rightAnchor.constraint(equalTo: rightAnchor).isActive 	= true
		sepLine.heightAnchor.constraint(equalToConstant: 1).isActive 	= true
		
		// кнопка "Отправить"
		sendButton.setImage(UIImage(named: "bttn_send"), for: .normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		addSubview(sendButton)
		sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
		sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive 	= true
		sendButton.widthAnchor.constraint(equalToConstant: 44).isActive 	= true
		sendButton.heightAnchor.constraint(equalToConstant: 44).isActive 	= true
		
		// текстовое поле
		addSubview(inputTextField)
		inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 10).isActive = true
		inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive		= true
		inputTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive 	= true
		inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive 				= true
	}
	
	
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = placeholderStr
			textView.textColor = UIColor.lightGray
		}
		sendButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
	

	
	
	public func textViewDidChange(_ textView: UITextView) {
		// отслеживаем "Enter" с клавиатуры
		if textView.text.last == "\n" {
			textView.text.removeLast()
			onSend()
			return
		}
		
		// textView самостоятельно увеличивает свой размер
		// по мере ввода текста
		
		// пересчитываем высоту self под новыую высоту textView
		self.invalidateIntrinsicContentSize()
		
		if textView.text.isEmpty {
			sendButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		}
		else {
			sendButton.tintColor = #colorLiteral(red: 0.1450980392, green: 0.5294117647, blue: 1, alpha: 1)
		}
	}


	
	
	/// пересчитываем собственный размер (высоту)
	override var intrinsicContentSize: CGSize {
		
		// высчитываем новый размер высоты
		let newSize = CGSize(width: inputTextField.bounds.width, height: .infinity)
		var estimatedSize = inputTextField.sizeThatFits(newSize)
		estimatedSize.height += 14
		print("intrinsicContentSize = \(estimatedSize.height)")
		print("inputTextField.frame.size = \(inputTextField.frame.size)")

		return estimatedSize
	}
	
	
	
	@objc private func onSend(){
		if inputTextField.textColor == UIColor.lightGray{
			return
		}
		self.invalidateIntrinsicContentSize()
		chatLogController?.onSendClick()
	}
	
	
	
	
	
	 
	
}














