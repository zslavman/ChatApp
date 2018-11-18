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
	private var playTimer:Any? // слушатель прогирывания видео
	private static let cornRadius:CGFloat = 12
	
	
	private let activityIndicator:UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		ai.translatesAutoresizingMaskIntoConstraints = false
		ai.hidesWhenStopped = true
		ai.isUserInteractionEnabled = false
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
		bubble.layer.cornerRadius = cornRadius
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
		messImag.layer.cornerRadius = ChatMessageCell.cornRadius
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
	
	private lazy var fullScreenBttn: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: "fullScreen"), for: .normal)
		button.tintColor = .white
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isUserInteractionEnabled = true
		button.addTarget(self, action: #selector(onFullScreenClick), for: .touchUpInside)
		button.alpha = 0.4
		button.layer.shadowRadius = 2
		button.layer.shadowOffset = CGSize(width: 1, height: 1)
		button.layer.shadowOpacity = 0.5
		return button
	}()
	
	private let progressBar:UIProgressView = {
		let prog = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
		prog.translatesAutoresizingMaskIntoConstraints = false
		prog.setProgress(0, animated: false)
		prog.tintColor = UIColor(r: 0, g: 255, b: 0)
		return prog
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
		addSubview(playButton)
		bubbleView.addSubview(activityIndicator)
		bubbleView.addSubview(progressBar)
		addSubview(fullScreenBttn)
		
		
		// для кнопки "полный экран"
		fullScreenBttn.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 5).isActive = true
		fullScreenBttn.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
		fullScreenBttn.widthAnchor.constraint(equalToConstant: 25).isActive = true
		fullScreenBttn.heightAnchor.constraint(equalToConstant: 25).isActive = true
		
		// для прогрессбара
		progressBar.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1).isActive 	= true
		progressBar.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 0).isActive = true
		progressBar.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0).isActive = true
		
		
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
	
	
	
	
	public func setupCell(linkToParent:ChatLogController, message:Message, indexPath:IndexPath){
		
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
			messageImageView.loadImageUsingCache(urlString: messageImageUrl){
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
		fullScreenBttn.isHidden = message.videoUrl == nil
	}
	
	
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		removePlayObserver()
		player?.pause()
		playerLayer?.removeFromSuperlayer()
		player = nil
		progressBar.setProgress(0, animated: false)
		messageImageView.image = nil
		
		activityIndicator.stopAnimating()
	}
	
	
	public func removePlayObserver(){
		if let _playTimer = playTimer{
			player?.removeTimeObserver(_playTimer)
			playTimer = nil
			//sendTime_TF.text = UserCell.convertTimeStamp(seconds: message?.timestamp as! TimeInterval, shouldReturn: false)
		}
	}
	
	
	/// клик на отправленной картинке в сообщении
	@objc private func onImageClick(tapGesture: UITapGestureRecognizer){
		if message?.videoUrl != nil {
			onStopPlay()
			return
		}
		if let imageView = tapGesture.view as? UIImageView{
			// хорошая практика - не перегружать вьюшки кучей логики, потому
			chatlogController?.performZoomForImageView(imageView: imageView)
		}
	}
	
	
	
	@objc private func onPlayClick(){
		if let videoUrlString = message?.videoUrl, let videoUrl = URL(string: videoUrlString){
			if (player == nil){
				player = AVPlayer(url: videoUrl)
				playerLayer = AVPlayerLayer(player: player)
				playerLayer?.frame = bubbleView.bounds
	
				bubbleView.layer.addSublayer(playerLayer!)
				activityIndicator.startAnimating() // когда загрузится видео, оно его перекроет
				
				// перемещаем прогрессбар на верхний слой (иначе playerLayer его закроет)
				bubbleView.bringSubview(toFront:progressBar)
			}
			
			removePlayObserver()
			
			player?.play()
			playButton.isHidden = true
			
			if playTimer != nil { return }
			
			// запустим таймер с интервалом 1/20 с (value / timescale)
			let interval = CMTime(value: 1, timescale: 20)
			playTimer = player!.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {
				[weak self] (cmtime) in
				self?.sendTime_TF.text = ChatMessageCell.convertTime(seconds: cmtime.seconds)
				
				
				if let endTime = self?.player?.currentItem?.duration.seconds{
					let percentComplete = cmtime.seconds / endTime
					// print("percentComplete = \(String(format: "%.0f", percentComplete * 100))")
					if !percentComplete.isNaN { // на реальных устройствах тут иногда выскакивает NaN
						self?.progressBar.setProgress(Float(percentComplete), animated: true)
					}
					// при окончании воспроизведения
					if cmtime.seconds == endTime{
						self?.didPlayToEnd()
					}
				}
				
			})
			
			//	if let playTime = self.player?.currentItem?.currentTime().seconds{
			//		let str = ChatMessageCell.convertTime(seconds: playTime)
			//		self.sendTime_TF.text = str
			//	}
			
			// наблюдатель окончания проигрывания видео
			// NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEnd), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
		}
	}
	
	
	
	// переход на фулскрин просморт
	@objc private func onFullScreenClick(){
		if let videoUrlString = message?.videoUrl, let videoUrl = URL(string: videoUrlString){
			var seek = CMTime(seconds: 0, preferredTimescale: 1)
			if player != nil {
				seek = player!.currentTime()
				onStopPlay()
			}
			chatlogController?.runNativePlayer(videoUrl: videoUrl, currentSeek: seek)
			return
		}
	}
	
	
	
	
	
	/// преобразует секунды в формат ММ:СС
	public static func convertTime(seconds:Double) -> String{
		let intValue = Int(seconds)
		// let hou = intValue / 3600
		let min = intValue / 60
		let sec = intValue % 60
		let time = String(format: "%2i:%02i", min, sec)
		
		return time
	}
	
	
	
	private func onStopPlay(){
		if isPlaying {
			removePlayObserver()
			playButton.isHidden = false
			player?.pause()
		}
	}
	
	
	
	
	@objc private func didPlayToEnd(){
		playButton.isHidden = false
		player!.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
		removePlayObserver()
		progressBar.setProgress(0, animated: false)
		sendTime_TF.text = ChatMessageCell.convertTime(seconds: 0)
	}
	
	
	
	
	
	
	
}





















