//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 08.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


class ChatMessageCell: UICollectionViewCell { // без MKMapViewDelegate будет ругатся на компас!
	
	public var chatlogController:ChatLogController?
	internal var message:Message?
	
	public static let blueColor = UIColor(r: 215, g: 235, b: 255)
	public static let grayColor = UIColor(r: 239, g: 239, b: 238)
	public static let grayTextColor = UIColor(r: 127, g: 138, b: 150)
	
	public var bubbleWidthAnchor: NSLayoutConstraint?
	public var bubbleRightAnchor: NSLayoutConstraint?
	public var bubbleLeftAnchor: NSLayoutConstraint?
	
	public static let cornRadius:CGFloat = 12

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
		bubble.translatesAutoresizingMaskIntoConstraints = false
		bubble.backgroundColor = blueColor
		bubble.layer.cornerRadius = cornRadius
		// bubble.layer.shadowPath = UIBezierPath(roundedRect: bubble.bounds, cornerRadius: cornRadius).cgPath // не работает
		bubble.layer.shadowOffset = CGSize(width: 0, height: 0.5)
		bubble.layer.shadowRadius = 0.75
		bubble.layer.shadowOpacity = 0.6
		bubble.layer.masksToBounds = true
		bubble.layer.borderColor = UIColor.black.withAlphaComponent(0.26).cgColor
		bubble.layer.borderWidth = 0.5
//		var shadowLayer = CAShapeLayer()
//		shadowLayer.path = UIBezierPath(roundedRect: bubble.bounds, cornerRadius: ChatMessageCell.cornRadius).cgPath
//		shadowLayer.fillColor = UIColor.black.cgColor
//		shadowLayer.shadowColor = UIColor.black.cgColor
//		shadowLayer.shadowPath = shadowLayer.path
//		shadowLayer.shadowOffset = CGSize(width: 0, height: 5.5)
//		shadowLayer.shadowRadius = 0.75
//		shadowLayer.shadowOpacity = 0.6
//		bubble.layer.insertSublayer(shadowLayer, at: 0)
		return bubble
	}()

	
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
		label.backgroundColor = UIColor.clear
		label.textColor = grayTextColor
		label.isEditable = false
		label.isScrollEnabled = false
		return label
	}()
	
	

	

	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(bubbleView)
		addSubview(textView)
		addSubview(sendTime_TF)
		addSubview(profileImageView)
		
		NSLayoutConstraint.activate([
			
			// для фото собеседника
			profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
			profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
			profileImageView.widthAnchor.constraint(equalToConstant: 32),
			profileImageView.heightAnchor.constraint(equalToConstant: 32),
			
			// для времени отправки
			sendTime_TF.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
			sendTime_TF.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -15),
			sendTime_TF.widthAnchor.constraint(equalToConstant: 80),
			sendTime_TF.heightAnchor.constraint(equalToConstant: 20),
			
			// для текста сообщения
			textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8),
			textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
			textView.topAnchor.constraint(equalTo: topAnchor),
			textView.heightAnchor.constraint(equalTo: heightAnchor),
			
			// для фона сообщения
			bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
			bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
		])
		
		//  для фона сообщения
		bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
		bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
		bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200) // тут не важно, т.к. будет переопределяться
		bubbleLeftAnchor?.isActive = false // отключена по дефолту
		bubbleRightAnchor?.isActive = true
		bubbleWidthAnchor?.isActive = true
	}
	

//	override var isSelected: Bool {
//		get {
//			return super.isSelected
//		}
//		set {
//			if newValue {
//				super.isSelected = true
//				print("selected")
//			}
//			else if newValue == false {
//				super.isSelected = false
//				print("deselected")
//			}
//		}
//	}

	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	/// вызывается только из ChatLogController
	public func setupCell(linkToParent:ChatLogController, message:Message, indexPath:IndexPath){
		
		chatlogController = linkToParent
		self.message = message
		
		textView.text = message.text
		sendTime_TF.text = Calculations.convertTimeStamp(seconds: message.timestamp as! TimeInterval, shouldReturn: false)
		
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
			bubbleRightAnchor?.isActive = false
			bubbleLeftAnchor?.isActive = true
		}
		
		sendTime_TF.layer.shadowOpacity = 0
		sendTime_TF.textColor = ChatMessageCell.grayTextColor
		
		// изменим ширину фона сообщения (высота же определяется в ChatLogController sizeForItemAt)
		if let str = message.text{
			let estWidth = linkToParent.estimatedFrameForText(text: str).width + 30
			bubbleWidthAnchor?.constant = estWidth < 60 ? 60 : estWidth
		}
		
//		isSelected = !message.readStatus!
		
	}



	
	
}





















