//
//  Image_Cell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 01.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit


class Image_Cell: ChatMessageCell {
	
	
	
	private lazy var messageImageView:UIImageView = {
		let messImag = UIImageView()
		messImag.translatesAutoresizingMaskIntoConstraints = false
		messImag.contentMode = .scaleAspectFill
		messImag.layer.cornerRadius = ChatMessageCell.cornRadius
		messImag.clipsToBounds = true
		messImag.isUserInteractionEnabled = true
		// если использовать в этом кложере target: self, то нужно чтоб переменная была lazy!!
		messImag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageClick)))
		return messImag
	}()
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override init(frame: CGRect){
		super.init(frame: frame)
		
		bubbleView.addSubview(messageImageView)
		
		NSLayoutConstraint.activate([
			// для вложенного фото в сообщении (если такоевое будет)
			messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
			messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
			messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
			messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)
		])
	}
		
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	/// вызывается только из ChatLogController
	override func setupCell(linkToParent: ChatController, message: Message, indexPath: IndexPath) {
		super.setupCell(linkToParent: linkToParent, message: message, indexPath: indexPath)
		
		// загружаем картинку сообщения
		messageImageView.loadImageUsingCache(urlString: message.imageUrl!){
			(image) in
			// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
			// и обновить ее в главном потоке
			DispatchQueue.main.async {
				if self.tag == indexPath.item{
					self.messageImageView.image = image
				}
			}
		}
		messageImageView.isHidden = false
		bubbleView.backgroundColor = .clear
		textView.isHidden = true
		
		sendTime_TF.layer.shadowRadius = 0.5
		sendTime_TF.layer.shadowColor = UIColor.black.cgColor
		sendTime_TF.layer.shadowOffset = CGSize(width: 0, height: 0.5)
		sendTime_TF.layer.shadowOpacity = 1
		sendTime_TF.textColor = .white
		
		bubbleWidthAnchor?.constant = UIScreen.main.bounds.width * 2/3
	}
	
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		messageImageView.image = nil
	}
	
	
	
	
	/// клик на отправленной картинке в сообщении
	@objc private func onImageClick(tapGesture: UITapGestureRecognizer){
		if let imageView = tapGesture.view as? UIImageView{
			// хорошая практика - не перегружать вьюшки кучей логики, потому
			chatlogController?.performZoomForImageView(imageView: imageView)
		}
	}
	
	
}





















