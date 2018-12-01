//
//  ChatMess_Video.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 30.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import AVFoundation



class Video_Cell: ChatMessageCell {
	
	
	private let activityIndicator:UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		ai.translatesAutoresizingMaskIntoConstraints = false
		ai.hidesWhenStopped = true
		ai.isUserInteractionEnabled = false
		return ai
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
	
	
	private lazy var videoPreviewImage:UIImageView = {
		let messImag = UIImageView()
		messImag.translatesAutoresizingMaskIntoConstraints = false
		messImag.contentMode = .scaleAspectFill
		messImag.layer.cornerRadius = ChatMessageCell.cornRadius
		messImag.clipsToBounds = true
		messImag.isUserInteractionEnabled = true
		// если использовать в этом кложере target: self, то нужно чтоб переменная была lazy!!
		messImag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStopPlay)))
		return messImag
	}()
	
	
	/// кастомная проверка играет ли плеер сейчас (A*ple не создали вообще никакой проверки)
	public var isPlaying: Bool {
		if let player = player {
			if player.rate != 0 && player.error == nil{
				return true
			}
		}
		return false
	}
	
	
	
	public var player: AVPlayer?
	public var playerLayer: AVPlayerLayer?
	private var playTimer:Any? // слушатель прогирывания видео
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override init(frame: CGRect){
		super.init(frame: frame)
		
		bubbleView.addSubview(videoPreviewImage)
		bubbleView.addSubview(activityIndicator)
		bubbleView.addSubview(progressBar)
		addSubview(fullScreenBttn)
		addSubview(playButton)
		
		NSLayoutConstraint.activate([
			// для прогрессбара
			progressBar.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1),
			progressBar.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 0),
			progressBar.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0),
			
			// констрейнты для кнопки "полный экран"
			fullScreenBttn.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 5),
			fullScreenBttn.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10),
			fullScreenBttn.widthAnchor.constraint(equalToConstant: 25),
			fullScreenBttn.heightAnchor.constraint(equalToConstant: 25),
			
			// активити-индикатор (при нажатии на плей)
			activityIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
			activityIndicator.widthAnchor.constraint(equalToConstant: 50),
			activityIndicator.heightAnchor.constraint(equalToConstant: 50),
			
			// для кнопки Плей
			playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
			playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
			playButton.widthAnchor.constraint(equalToConstant: 40),
			playButton.heightAnchor.constraint(equalToConstant: 50),
			
			// для превью видео
			videoPreviewImage.topAnchor.constraint(equalTo: bubbleView.topAnchor),
			videoPreviewImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
			videoPreviewImage.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
			videoPreviewImage.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)
		])
		
	}
	
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		progressBar.setProgress(0, animated: false)
		removePlayObserver()
		onStopPlay()
		playerLayer?.removeFromSuperlayer()
		player = nil
		activityIndicator.stopAnimating()
		videoPreviewImage.image = nil
	}
	
	
	
	
	/// вызывается только из ChatLogController
	override func setupCell(linkToParent: ChatLogController, message: Message, indexPath: IndexPath) {
		super.setupCell(linkToParent: linkToParent, message: message, indexPath: indexPath)
		
		if let messageImageUrl = message.imageUrl {
			videoPreviewImage.loadImageUsingCache(urlString: messageImageUrl){
				(image) in
				// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
				DispatchQueue.main.async {
					if self.tag == indexPath.item{
						self.videoPreviewImage.image = image
					}
				}
			}
		}
		bubbleView.backgroundColor = .clear
		textView.isHidden = true
		
		sendTime_TF.layer.shadowRadius = 0.5
		sendTime_TF.layer.shadowColor = UIColor.black.cgColor
		sendTime_TF.layer.shadowOffset = CGSize(width: 0, height: 0.5)
		sendTime_TF.layer.shadowOpacity = 1
		sendTime_TF.textColor = .white

		bubbleWidthAnchor?.constant = UIScreen.main.bounds.width * 2/3
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
	
	
		
	/// клик на отправленной картинке в сообщении или же при переходе в фулскрин
	@objc private func onStopPlay(){
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
	
	
	
	
	public func removePlayObserver(){
		if let _playTimer = playTimer{
			player?.removeTimeObserver(_playTimer)
			playTimer = nil
			//sendTime_TF.text = UserCell.convertTimeStamp(seconds: message?.timestamp as! TimeInterval, shouldReturn: false)
		}
	}
	
	
	
}















