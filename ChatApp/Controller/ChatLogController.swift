//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 06.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

import AVKit

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	public var user:User? {
		didSet{
			navigationItem.title = user?.name
			observeMessages()
		}
	}
	
	private lazy var inputTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Введите текст..."
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.delegate = self
		return tf
	}()
	
	
	private lazy var inputContainerView: UIView = {
		// контейнер + фон
		let containerView = UIView()
		containerView.backgroundColor = .white
		containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
		containerView.translatesAutoresizingMaskIntoConstraints = false
//		view.addSubview(containerView)
//		containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//		containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
//		containerViewBottomAnchor?.isActive = true
//		containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//		containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		
		// картинка слева (отправить фото)
		let uploadImageView = UIImageView()
		uploadImageView.image = UIImage(named: "upload_image_icon")
		containerView.addSubview(uploadImageView)
		uploadImageView.translatesAutoresizingMaskIntoConstraints = false
		uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
		uploadImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
		uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true // эпл рекомендует размер 44
		uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
		uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onUploadClick)))
		uploadImageView.isUserInteractionEnabled = true
		
		// линия-сепаратор
		let sepLine = UIView()
		sepLine.backgroundColor = UIColor.lightGray
		sepLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 1)
		sepLine.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(sepLine)
		sepLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
		sepLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
		sepLine.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		sepLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		
		// кнопка
		let sendButton = UIButton(type: .system) // .system - для того, чтоб у кнопки были состояния нажатая/отжатая
		sendButton.setTitle("Отправ.", for: UIControlState.normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.addTarget(self, action: #selector(onSendClick), for: UIControlEvents.touchUpInside)
		containerView.addSubview(sendButton)
		sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
		sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
		sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
		sendButton.layer.cornerRadius = 10
		
		// текстовое поле
		containerView.addSubview(self.inputTextField)
		self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 10).isActive = true
		self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
		self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
		self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
		
		return containerView
	}()
	
	
	private let cell_ID:String = "cell_ID"
	private var messages:[Message] = []
	private var containerViewBottomAnchor:NSLayoutConstraint?
	
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
		layout?.minimumLineSpacing = 12 // расстояние сверху и снизу ячеек (по дефолту = 12)
		
		collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0) // вставляем поля чтоб чат не соприкосался сверху и снизу
		collectionView?.alwaysBounceVertical = true
		collectionView?.backgroundColor = .white
		collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cell_ID)
		
		// поведение клавиатуры при скроллинге
		collectionView?.keyboardDismissMode = .interactive
		
		// слушатель на тап по фону сообщений
		collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChatBackingClick)))
		
		// прослушиватели клавы
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
		
		//		setupInputComponents()
		//
		//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	
	
	/// прицепляем "аксессуар" в виде вьюшки на клавиатуру
	override var inputAccessoryView: UIView? {
		get {
			return inputContainerView
		}
	}
	override var canBecomeFirstResponder: Bool {
		return true // без этого не отображается inputContainerView
	}
	
	
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self) // слушатели всегда нужно убирать, иначе будет утечка памяти и многократное срабатывание
		
		// перебираем все видимые ячейки, на предмет проигрывания вних видео
		guard let cells = collectionView?.visibleCells as? [ChatMessageCell] else { return }
		cells.forEach {
			(cell) in
			if cell.isPlaying{
				print("Останавливаем воспроизведение!")
				cell.removePlayObserver()
				cell.player?.pause()
				cell.playerLayer?.removeFromSuperlayer()
			}
		}
	}
	
	
	
	/// переопеределяем констрайнты при каждом повороте экрана (на некоторых моделях телефонов если не сделать - будет залазить/вылазить справа весь контент скролвьюшки)
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		collectionView?.collectionViewLayout.invalidateLayout()

		if (startingFrame != nil){
			// прячем, т.к. по непонятной причине при повороте появляется inputContainerView
			inputContainerView.isHidden = true

			// пересчитываем кадр куда возвращатся с просмотра картинки
//			print("orig = \(orig?.frame)")
//			startingFrame = orig?.convert((originalImageView?.frame)!, to: nil)
		}
		else{
			collectionView?.reloadData()
		}
	}
	

	
	
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_ID, for: indexPath) as! ChatMessageCell
		
		cell.tag = indexPath.item
		let message = messages[indexPath.item]
		cell.setupCell(linkToParent: self, message: message, indexPath: indexPath)
		
		return cell
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var hei:CGFloat = 80
		
		let message = messages[indexPath.item]
		
		// получаем ожидаемую высоту
		if let text = message.text {
			hei = estimatedFrameForText(text: text).height + 20 + 10 //(10 - для времени)
		}
		else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
			
			// h1/w1 = h2/w2  ->  h1 = h2/w2 * w1
			let w1:CGFloat = CGFloat(UIScreen.main.bounds.width * 2/3)
			hei = (CGFloat(imageHeight) / CGFloat(imageWidth) * w1)
			
		}
		
		
		return CGSize(width: UIScreen.main.bounds.width, height: hei)
		
	}
	
	
	
	
	
	
	
	/// подсчет ожидаемых размеров текстового поля
	public func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: UIScreen.main.bounds.width * 2/3, height: .infinity)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	

	
	
	
	private func observeMessages(){
		
		guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else { return }
		
		let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toID) // ссылка на список сообщений
		userMessagesRef.observe(.childAdded, with: {
			(snapshot) in
			
			let messagesRef = Database.database().reference().child("messages").child(snapshot.key) // ссылка на сами сообщения
			
			messagesRef.observeSingleEvent(of: .value, with: {
				(snapshot) in
				
				guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
					
				let message = Message(dictionary: dictionary)
//				message.setValuesForKeys(dictionary)
				
				self.messages.append(message)
				
				// нужна ли сортировка????
				self.messages.sort(by: {
					(message1, message2) -> Bool in
					return (message1.timestamp?.intValue)! < (message2.timestamp?.intValue)!
				})
				
				DispatchQueue.main.async {
					self.collectionView?.reloadData()
					// прокручиваем скролл вниз
					self.collectionView?.scrollToLast()
				}
				
			}, withCancel: nil)
			
		}, withCancel: nil)
	}



	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		onSendClick()
		return true
	}
	
	
	@objc private func onChatBackingClick(){
		inputTextField.resignFirstResponder()
	}
	
	
	
	@objc private func keyboardDidShow(notif: Notification){
		
		if let keyboardFrame = (notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
			// при повороте экрана происходит ложное срабатывание - клава не выезжает (но высота ее = 50), потому проверяем ее размер
			if keyboardFrame.height > 100 {
				collectionView?.scrollToLast()
			}
		}
	}
	
	
	
	
	
	/// клик на картинку (переслать фотку)
	@objc private func onUploadClick(){
		let imagePickerController = UIImagePickerController()
		
		imagePickerController.allowsEditing = true
		imagePickerController.delegate = self
		// разрешаем выбирать видеофайлы из библиотеки
		imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
		
		present(imagePickerController, animated: true, completion: nil)
	}
	
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		var permission:Bool = true
		
		// если выбрали видеофайл
		if let videoURL = info[UIImagePickerControllerMediaURL] as? URL{
			if let bytes = NSData(contentsOf: videoURL)?.length{ // в обычной Data нет свойства length
				let MB = (bytes / 1024) / 1000
				print("Размер файла = \(MB) МБ")
				if MB > 10 {
					permission = false
				}
			}
			if permission {
				videoSelectedForInfo(videoFilePath: videoURL)
			}
		}
		else { // если выбрали фото
			imageSelectedForInfo(info: info)
		}
		
		
		dismiss(animated: true, completion: {
			if !permission{
				let message = "Выберите другое видео (не более 10 МБ), или сократите его длительность"
				let alertController = UIAlertController(title: "Слишком большой файл", message: message, preferredStyle: .alert)
				let ok = UIAlertAction(title: "Ок", style: .default, handler: nil)
				alertController.addAction(ok)
				
				self.present(alertController, animated: true, completion: nil)
				return
			}
		})
	}
	
	
	
	private func imageSelectedForInfo(info:[String: Any]){
		var selectedImage:UIImage?
		if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
			selectedImage = editedImage
		}
		else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
			selectedImage = originalImage
		}
		
		if let selectedImage = selectedImage {
			uploadingImageToStorage(image: selectedImage, completion: {
				(imageUrl) in
				self.sendMessageWithImage(imageUrl: imageUrl, image: selectedImage)
			})
		}
	}
	
	
	
	
	/// Когда выбрали видеофайл для выгрузки
	///
	/// - Parameter videoURL: внутренняя ссылка на видео (ссылка ведущя в альбом с видеофайлом)
	/// - 	restriction: разрешение загружать, если false - не загружаем
	private func videoSelectedForInfo(videoFilePath:URL){
		
		let uniqueImageName = UUID().uuidString
		let ref = Storage.storage().reference().child("message_videos").child("\(uniqueImageName).mov")
		
		let uploadTask = ref.putFile(from: videoFilePath, metadata: nil) {
			(metadata, error) in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			ref.downloadURL(completion: {
				(url, errorFromGettinfPicLink) in
				
				if let errorFromGettinfPicLink = errorFromGettinfPicLink {
					print(errorFromGettinfPicLink.localizedDescription)
					return
				}
				if let videoUrl = url?.absoluteString{
					// нам нужен первый кадр с видео для картинки
					if let thumbnailImge = self.thumbnailImageForFileURL(fileUrl: videoFilePath){
						self.uploadingImageToStorage(image: thumbnailImge, completion: {
							(imageUrl) in
							
							let properties:[String:Any] = [
								"imageWidth"	:thumbnailImge.size.width,
								"imageHeight"	:thumbnailImge.size.height,
								"videoUrl"		:videoUrl,
								"imageUrl"		:imageUrl
							]
							self.sendMessage_with_Properties(properties: properties)
						})
					}
				}
			})
		}
		
		uploadTask.observe(.progress) {
			(snapshot) in
			if let currentCount = snapshot.progress?.completedUnitCount, let totalCount = snapshot.progress?.totalUnitCount{
				let percentComplete = 100 * Double(currentCount) / Double(totalCount)
				self.navigationItem.title = String(format: "%.0f", percentComplete) + " %"
			}
		}
		uploadTask.observe(.success) {
			(snapshot) in
			self.navigationItem.title = self.user?.name
		}
	}
	
	
	
	///  Генерирует картинку первого кадра видеофайла
	///
	/// - Parameter fileUrl: путь к видеофайлу на телефоне
	private func thumbnailImageForFileURL(fileUrl: URL) -> UIImage? {
		
		let avasset = AVAsset(url: fileUrl)
		let imageGenerator = AVAssetImageGenerator(asset: avasset)
		let cmtime = CMTime(value: 1, timescale: 60)
		
		do {
			let thumbnail_CGImage = try imageGenerator.copyCGImage(at: cmtime, actualTime: nil)
			return UIImage(cgImage: thumbnail_CGImage)
		}
		catch let err{
			print(err.localizedDescription)
		}
		
		return nil
	}
	
	
	
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	
	
	
	/// Загрузка картинки в хранилище
	///
	/// - Parameters:
	///   - image: сама картинка
	///   - completion: фукнция которая дернется когда будет загружена картинка и получен на нее URL
	private func uploadingImageToStorage(image:UIImage, completion: @escaping (_ imageUrl:String) -> Void){
		let uniqueImageName = UUID().uuidString
		let ref = Storage.storage().reference().child("message_images").child("\(uniqueImageName).jpg")
		
		if let uploadData = UIImageJPEGRepresentation(image, 0.5){
			ref.putData(uploadData, metadata: nil, completion: {
				(metadata, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
				// когда получаем метадату, даем запрос на получение ссылки на эту картинку (разработчкики Firebase 5 - дауны)
				ref.downloadURL(completion: {
					(url, errorFromGettinfPicLink) in
					
					if let errorFromGettinfPicLink = errorFromGettinfPicLink {
						print(errorFromGettinfPicLink.localizedDescription)
						return
					}
					if let imageUrl = url{
						// запускаем ф-цию обратного вызова
						completion(imageUrl.absoluteString)
					}
				})
				print("удачно сохранили картинку")
			})
		}
	}
	
	
	
	
	@objc private func onSendClick(){
		if inputTextField.text == "" || inputTextField.text == " " { return }
		
		let properties:[String:Any] = [
			"text" :inputTextField.text!
		]
		sendMessage_with_Properties(properties: properties)
		
		inputTextField.text = nil
		inputTextField.resignFirstResponder()
	}
	
	
	/// сохранение сообщения с картинкой в БД
	private func sendMessageWithImage(imageUrl: String, image: UIImage){
		let properties:[String:Any] = [
			"imageUrl"		:imageUrl,
			"imageWidth"	:image.size.width,
			"imageHeight"	:image.size.height
		]
		sendMessage_with_Properties(properties: properties)
	}
	
	
	
	
	
	private func sendMessage_with_Properties(properties: [String:Any]){
		let ref = Database.database().reference().child("messages")
		// генерация псевдо-рандомных ключей сообщения https://chatapp-2222e.firebaseio.com/messages/-LQe7kjoAJkrVNzOjERM
		let childRef = ref.childByAutoId()
		
		let toID = user!.id!
		let fromID = Auth.auth().currentUser!.uid
		let timestamp:Int = Int(NSDate().timeIntervalSince1970)
		
		var values:[String:Any] = [
			"toID"		:toID,
			"fromID"	:fromID,
			"timestamp"	:timestamp
		]
		
		// добавляем к словарю values ключ + значения словаря properties (key = $0, value = $1)
		properties.forEach({values[$0] = $1})
		
		childRef.updateChildValues(values) {
			(error:Error?, ref:DatabaseReference) in
			if error != nil {
				print(error?.localizedDescription ?? "*")
				return
			}
			
			let messRef = Database.database().reference().child("user-messages")
			
			// создаем структуру цепочки сообщений ОТ определенного пользователя (тут будут лишь ID сообщений)
			let senderRef = messRef.child(fromID).child(toID)
			let messageID = childRef.key!
			senderRef.updateChildValues([messageID: 1])
			
			// создаем структуру цепочки сообщений ДЛЯ определенного пользователя (тут будут лишь ID сообщений)
			let recipientRef = messRef.child(toID).child(fromID)
			recipientRef.updateChildValues([messageID: 1])
		}
	}
	
	
	
	private var startingFrame:CGRect?
	private var blackBackgroundView:UIView?
	private var originalImageView:UIView?
	
	private var orig:UIView?
	
	/// кастомный зум при клике на отосланную картинку в чате
	public func performZoomForImageView(imageView: UIImageView){
		
		// прячем оригинальное изображение при клике на него
		originalImageView = imageView
		originalImageView?.isHidden = true
		orig = imageView.superview
		
		// определяем фрейм картинки для рендера
		startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
		
		// создаем картинку которая будет зумится
		let zoomingImageView = UIImageView(frame: startingFrame!)
		zoomingImageView.image = imageView.image
		zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onZoomedImageClick)))
		zoomingImageView.isUserInteractionEnabled = true
		zoomingImageView.layer.cornerRadius = 12
		zoomingImageView.clipsToBounds = true
		
		zoomingImageView.contentMode = .scaleAspectFit
		zoomingImageView.translatesAutoresizingMaskIntoConstraints = false
		
		// находим в иерархии окон нужное окно (куда будем добавлять вьюшку)
		if let keyWindow = UIApplication.shared.keyWindow {
			
			// добавляем чёрный фон
			blackBackgroundView = UIView(frame: keyWindow.frame)
			blackBackgroundView?.backgroundColor = .black
			// начальный альфа для фона (чтоб плавно анимировалось)
			blackBackgroundView?.alpha = 0
			
			keyWindow.addSubview(blackBackgroundView!)
			keyWindow.addSubview(zoomingImageView)
			
			blackBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
			blackBackgroundView?.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive 		= true
			blackBackgroundView?.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive 	= true
			blackBackgroundView?.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive 		= true
			blackBackgroundView?.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive 	= true
			
			zoomingImageView.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive 		= true
			zoomingImageView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive 	= true
			zoomingImageView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive 		= true
			zoomingImageView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive 	= true
			
			
			// *****************
			// * Блок анимации *
			// *****************
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				
				self.blackBackgroundView?.alpha = 1
				self.inputContainerView.alpha = 0 // вьюшка ввода сообщения
				zoomingImageView.layer.cornerRadius = 0
				
				// по отношению сторон (умножаем коэфф. соотношения сторон на размер известной ширины)
				let newHeight = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
				zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: newHeight)
				zoomingImageView.center = keyWindow.center
			})
		}
	}
	

	

	@objc private func onZoomedImageClick(tapGesture: UITapGestureRecognizer){
		
		if let tapedImageView = tapGesture.view{
			
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				
				tapedImageView.frame = self.startingFrame!
				self.startingFrame = nil
				self.blackBackgroundView?.alpha = 0
				self.inputContainerView.alpha = 1
				tapedImageView.layer.cornerRadius = 12
				tapedImageView.clipsToBounds = true
			}, completion: {
				(completed:Bool) in
				tapedImageView.removeFromSuperview()
				self.blackBackgroundView = nil
				self.blackBackgroundView?.removeFromSuperview()
				self.originalImageView?.isHidden = false
				self.inputContainerView.isHidden = false
			})
		}
	}
	
	
	
	
	
	
	/// воспроизведение видео на нативном плеере в фулскрине
	public func runNativePlayer(videoUrl: URL, currentSeek:CMTime){
		let player = AVPlayer(url: videoUrl)
		player.currentItem?.seek(to: currentSeek) // устанавливаем время начала воспроизведения
		let vc = AVPlayerViewController()
		vc.player = player
		
		present(vc, animated: true) {
			vc.player?.play()
		}
	}
	
	
	
	
	
	//	@objc private func keyboardWillShow(notif: Notification){
	//		if let keyboardFrame = (notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
	//			self.containerViewBottomAnchor?.constant = -keyboardFrame.height
	//		}
	//		// находим значение длительности анимации выезжания клавиатуры
	//		let keyboardDuration = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
	//
	//		// добавляем анимацию передвигания inputTextField (синхронно с выезжанием клавиатуры)
	//		UIView.animate(withDuration: keyboardDuration) {
	//			self.view.layoutIfNeeded()
	//		}
	//	}
	
	
	//	@objc private func keyboardWillHide(notif: Notification){
	//		containerViewBottomAnchor?.constant = 0
	//		let keyboardDuration = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
	//		UIView.animate(withDuration: keyboardDuration) {
	//			self.view.layoutIfNeeded()
	//		}
	//	}
	
	//	private func setupInputComponents(){
	//
	//		// контейнер + фон
	//		let containerView = UIView()
	//		containerView.backgroundColor = .white
	//		containerView.translatesAutoresizingMaskIntoConstraints = false
	//		view.addSubview(containerView)
	//		containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
	//
	//		containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
	//		containerViewBottomAnchor?.isActive = true
	//
	//		containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
	//		containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
	//
	//		// линия-сепаратор
	//		let sepLine = UIView()
	//		sepLine.backgroundColor = UIColor.lightGray
	//		sepLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 1)
	//		sepLine.translatesAutoresizingMaskIntoConstraints = false
	//		containerView.addSubview(sepLine)
	//		sepLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
	//		sepLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
	//		sepLine.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
	//		sepLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
	//
	//		// кнопка
	//		let sendButton = UIButton(type: .system) // .system - для того, чтоб у кнопки были состояния нажатая/отжатая
	//		sendButton.setTitle("Send", for: UIControlState.normal)
	//		sendButton.translatesAutoresizingMaskIntoConstraints = false
	//		sendButton.addTarget(self, action: #selector(onSendClick), for: UIControlEvents.touchUpInside)
	//		containerView.addSubview(sendButton)
	//		sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
	//		sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
	//		sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
	//		sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
	//		sendButton.layer.cornerRadius = 10
	//
	//		// текстовое поле
	//		containerView.addSubview(inputTextField)
	//		inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
	//		inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
	//		inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
	//		inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
	//	}
	
	
	
}



extension UICollectionView {
	
	func scrollToLast() {
		guard numberOfSections > 0 else { return }
		
		let lastSection = numberOfSections - 1
		
		guard numberOfItems(inSection: lastSection) > 0 else { return }
		
		let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
		
		scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
	}
	
}

















