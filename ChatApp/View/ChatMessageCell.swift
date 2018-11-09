//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 08.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
	
	
	public static let blueColor = UIColor(r: 0, g: 140, b: 250)
	public static let grayColor = UIColor(r: 220, g: 220, b: 220)
	
	public let textView: UITextView = {
		let label = UITextView()
		label.text = "Опять три рубляя!!"
		label.font = UIFont.systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .clear
		label.textColor = .white
		label.isEditable = false // после установки canBecomeFirstResponder в ChatLogController это поле стает редактируемым
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
	
	
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(bubbleView)
		addSubview(textView)
		addSubview(profileImageView)
		
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
		
		
		// констрейнты для текста сообщения
		textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive 	= true
		textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive 				= true
		textView.topAnchor.constraint(equalTo: self.topAnchor).isActive 						= true
		textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive 					= true
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}





















