//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 08.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

class ChatMessageCell: UICollectionViewCell {
	
	public var chatlogController:ChatLogController?
	
	public static let blueColor = UIColor(r: 215, g: 235, b: 255)
	public static let grayColor = UIColor(r: 239, g: 239, b: 238)
	public static let grayTextColor = UIColor(r: 127, g: 138, b: 150)
	
	public let textView: UITextView = {
		let label = UITextView()
		label.text = "Опять три рубляя!!"
		label.font = UIFont.systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .clear
		label.isEditable = false // после установки canBecomeFirstResponder в ChatLogController это поле стает редактируемым
		label.isScrollEnabled = false
		return label
	}()
	
	public let bubbleView: UIView = {
		let bubble = UIView()
		bubble.backgroundColor = blueColor
		bubble.translatesAutoresizingMaskIntoConstraints = false
		bubble.layer.cornerRadius = 12
		return bubble
	}()
	
	public var bubbleWidthAnchor: NSLayoutConstraint?
	public var bubbleRightAnchor: NSLayoutConstraint?
	public var bubbleLeftAnchor: NSLayoutConstraint?
	
	public let profileImageView: UIImageView = {
		let iView = UIImageView()
		iView.image = UIImage(named: "default_profile_image")
		iView.translatesAutoresizingMaskIntoConstraints = false
		iView.contentMode = .scaleAspectFill
		iView.layer.cornerRadius = 16
		iView.clipsToBounds = true
		return iView
	}()
	
	public let sendTime_TF:UITextView = {
		let label = UITextView()
		label.text = "18:59"
		label.textAlignment = .right
		label.font = UIFont.systemFont(ofSize: 10)
		label.translatesAutoresizingMaskIntoConstraints = false
//		label.backgroundColor = UIColor.red.withAlphaComponent(0.5)
		label.backgroundColor = UIColor.clear
		label.textColor = grayTextColor
		label.isEditable = false
		label.isScrollEnabled = false
		return label
	}()
	
	private lazy var messageImageView:UIImageView = {
		let messImag = UIImageView()
		messImag.translatesAutoresizingMaskIntoConstraints = false
		messImag.contentMode = .scaleAspectFill
		messImag.layer.cornerRadius = 12
		messImag.clipsToBounds = true
		messImag.isUserInteractionEnabled = true
		// если использовать в этом кложере target: self, то нужно чтоб переменная была lazy!!
		messImag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageClick)))
		return messImag
	}()
	
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(bubbleView)
		addSubview(textView)
		addSubview(sendTime_TF)
		addSubview(profileImageView)
		bubbleView.addSubview(messageImageView)
		
		// для вложенного фото в сообщении (если такоевое будет)
		messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive 			= true
		messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive 		= true
		messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive 		= true
		messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive 	= true
		
		// для фото собеседника
		profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive 	= true
		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive 					= true
		profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive 					= true
		
		// констрейнты для фона сообщения
		bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive 						= true
		bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive 				= true
		bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
		bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
		bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200) // тут не важно, т.к. будет переопределяться
		bubbleLeftAnchor?.isActive = false // отключена по дефолту
		bubbleRightAnchor?.isActive = true
		bubbleWidthAnchor?.isActive = true
		
		// для времени отправки
		sendTime_TF.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8).isActive = true
		sendTime_TF.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -15).isActive = true
		sendTime_TF.widthAnchor.constraint(equalToConstant: 80).isActive 						= true
		sendTime_TF.heightAnchor.constraint(equalToConstant: 20).isActive 						= true
		
		// констрейнты для текста сообщения
		textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive 	= true
		textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive 				= true
		textView.topAnchor.constraint(equalTo: self.topAnchor).isActive 						= true
		textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive 					= true
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	public func setupCell(linkToParent:ChatLogController, message:Message){
		
		chatlogController = linkToParent
		
		textView.text = message.text
		sendTime_TF.text = UserCell.convertTimeStamp(seconds: message.timestamp as! TimeInterval, shouldReturn: false)
		
		// определяем какием цветом будет фон сообщения
		// голубым (свои)
		if message.fromID == Auth.auth().currentUser?.uid {
			bubbleView.backgroundColor = ChatMessageCell.blueColor
			profileImageView.isHidden = true
			bubbleLeftAnchor?.isActive = false
			bubbleRightAnchor?.isActive = true
		}
		// серым (собеседника)
		else {
			bubbleView.backgroundColor = ChatMessageCell.grayColor
			profileImageView.isHidden = false
			
			if let profileImageUrl = linkToParent.user?.profileImageUrl {
				profileImageView.loadImageUsingCache(urlString: profileImageUrl, completionHandler: nil)
			}
			bubbleLeftAnchor?.isActive = true
			bubbleRightAnchor?.isActive = false
		}
		
		// загружаем картинку сообщения (если таковая имеется)
		if let messageImageUrl = message.imageUrl {
			messageImageView.loadImageUsingCache(urlString: messageImageUrl, completionHandler: nil)
			messageImageView.isHidden = false
			bubbleView.backgroundColor = .clear
			textView.isHidden = true
		}
		else {
			messageImageView.isHidden = true
			textView.isHidden = false
		}
		
		
		// изменим ширину фона сообщения
		if let str = message.text{
			let estWidth = linkToParent.estimatedFrameForText(text: str).width + 30
			bubbleWidthAnchor?.constant = estWidth < 60 ? 60 : estWidth
		}
		else if message.imageUrl != nil || message.videoUrl != nil {
			bubbleWidthAnchor?.constant = UIScreen.main.bounds.width * 2/3
		}
	}
	
	
	
	/// клик на отправленной картинке в сообщении
	@objc private func onImageClick(tapGesture: UITapGestureRecognizer){
		if let imageView = tapGesture.view as? UIImageView{
			// хорошая практика - не перегружать вьюшки кучей логики, потому
			chatlogController?.performZoomForImageView(imageView: imageView)
		}
	}
	
	
	
	
	
	
	
	
	
}





















