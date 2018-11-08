//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 08.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
	
	public let textView: UITextView = {
		let label = UITextView()
		label.text = "Опять три рубляя!!"
		label.font = UIFont.systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .clear
		label.textColor = .white
		return label
	}()
	
	private let bubbleView: UIView = {
		let bubble = UIView()
		bubble.backgroundColor = UIColor(r: 0, g: 140, b: 250)
		bubble.translatesAutoresizingMaskIntoConstraints = false
		bubble.layer.cornerRadius = 12
		return bubble
	}()
	
	public var bubbleWidthAnchor: NSLayoutConstraint?
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		
		addSubview(bubbleView)
		addSubview(textView)
		
		
		
		// констрейнты для фона сообщения
		bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive 						= true
		bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive 	= true
		bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive 				= true
//		bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 3/4)
		bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200) // тут не важно сколько, т.к. оно будет переопределяться
		bubbleWidthAnchor?.isActive = true
		
//		print("widthAnchor = \(UIScreen.main.bounds.width * 3/4)")
		
		
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





















