//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 08.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation


class ChatMessageCell: UICollectionViewCell {
	
	public var chatlogController:ChatLogController?
	private var message:Message?
	
	public static let blueColor = UIColor(r: 215, g: 235, b: 255)
	public static let grayColor = UIColor(r: 239, g: 239, b: 238)
	public static let grayTextColor = UIColor(r: 127, g: 138, b: 150)
	
	public var bubbleWidthAnchor: NSLayoutConstraint?
	public var bubbleRightAnchor: NSLayoutConstraint?
	public var bubbleLeftAnchor: NSLayoutConstraint?
	
	public var player: AVPlayer?
	public var playerLayer: AVPlayerLayer?
	
	
	
	private let activityIndicator:UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		ai.translatesAutoresizingMaskIntoConstraints = false
		ai.hidesWhenStopped = true
		return ai
	}()
	
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
		bubble.clipsToBounds = true
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
	
	private lazy var playButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: "play"), for: .normal)
		button.tintColor = .white
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isUserInteractionEnabled = true
		button.addTarget(self, action: #selector(onPlayClick), for: .touchUpInside)
		
		button.layer.shadowRadius = 5
		button.layer.shadowOffset = CGSize(width: 1, height: 2)
		button.layer.shadowOpacity = 0.8
		
		return button
	}()
	
	
	/// кастомная проверка играет ли плеер сейчас (дебилы эпл не создали вообще никакой проверки)
	public var isPlaying: Bool {
		if let player = player {
			if player.rate != 0 && player.error == nil{
				return true
			}
		}
		return false
	}
	
	
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(bubbleView)
		addSubview(textView)
		addSubview(sendTime_TF)
		addSubview(profileImageView)
		bubbleView.addSubview(messageImageView)
		bubbleView.addSubview(playButton)
		bubbleView.addSubview(activityIndicator)
		
		// для вложенного фото в сообщении (если такоевое будет)
		messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive 			= true
		messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive 		= true
		messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive 		= true
		messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive 	= true
		
		// для кнопки Плей
		playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive 		= true
		playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive 		= true
		playButton.widthAnchor.constraint(equalToConstant: 40).isActive 						= true
		playButton.heightAnchor.constraint(equalToConstant: 50).isActive 						= true

		// активити-индикатор (при нажатии на плей)
		activityIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive 		= true
		activityIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive 		= true
		activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive 						= true
		activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive 						= true
		
		
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
		self.message = message
		
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
			
			sendTime_TF.layer.shadowRadius = 0.5
			sendTime_TF.layer.shadowColor = UIColor.black.cgColor
			sendTime_TF.layer.shadowOffset = CGSize(width: 0, height: 0.5)
			sendTime_TF.layer.shadowOpacity = 1
			sendTime_TF.textColor = .white
		}
		else {
			messageImageView.isHidden = true
			textView.isHidden = false
			sendTime_TF.layer.shadowOpacity = 0
			sendTime_TF.textColor = ChatMessageCell.grayTextColor
		}
		
		
		// изменим ширину фона сообщения
		if let str = message.text{
			let estWidth = linkToParent.estimatedFrameForText(text: str).width + 30
			bubbleWidthAnchor?.constant = estWidth < 60 ? 60 : estWidth
		}
		else if message.imageUrl != nil ||  message.videoUrl != nil{
			bubbleWidthAnchor?.constant = UIScreen.main.bounds.width * 2/3
		}
		
		// прячем кнопку Плей на всех сообщениях которые не видео
		playButton.isHidden = message.videoUrl == nil
	}
	
	
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		player?.pause()
		playerLayer?.removeFromSuperlayer()
		
		activityIndicator.stopAnimating()
	}
	
	
	
	/// клик на отправленной картинке в сообщении
	@objc private func onImageClick(tapGesture: UITapGestureRecognizer){
		if message?.videoUrl != nil {
			if isPlaying{
				player?.pause()
				playButton.isHidden = false
//				playButton.inde
			}
			return
		}
		if let imageView = tapGesture.view as? UIImageView{
			// хорошая практика - не перегружать вьюшки кучей логики, потому
			chatlogController?.performZoomForImageView(imageView: imageView)
		}
	}
	
	
	@objc private func onPlayClick(){
		
		if let videoUrlString = message?.videoUrl, let videoUrl = URL(string: videoUrlString){
			
			player = AVPlayer(url: videoUrl)

			playerLayer = AVPlayerLayer(player: player)
			playerLayer?.frame = bubbleView.bounds
			bubbleView.layer.addSublayer(playerLayer!)
			
			player?.play()
			
			playButton.isHidden = true
			activityIndicator.startAnimating()
		}
	}
	
	
	
	
	
	
	
}





















