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
import CoreLocation

import AVKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	public var user:User? {
		didSet{
			navigationItem.title = user?.name
			observeMessages()
		}
	}
	
	private lazy var growingInputView: ChatInputView = {
		let inputView = ChatInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
		inputView.chatLogController = self
		return inputView
	}()
	
	struct cID {
		static let cell_ID:String 			= "cell_ID"
		static let cell_ID_video:String 	= "cell_ID_video"
		static let cell_ID_map:String 		= "cell_ID_map"
		static let cell_ID_image:String 	= "cell_ID_image"
	}
	
	private var messages:[Message] = []
	private var containerViewBottomAnchor:NSLayoutConstraint?
	private var disposeVar1:(DatabaseReference, UInt)!
	private var disposeVar2:(DatabaseReference, UInt)!
	private var flag:Bool = false 			// флаг, что открыто окно выбора картинки (false - слушатель удаляется)
	private var dataArray = [[Message]]() 	// двумерный массив сообщений в секциях
	private var stringedTimes = [String]()	// массив конвертированных в строку дат сообщений (для заглавьяь секций)
	private let headerReusableView:String = "sectionHeader"
	
	private var primaryDataloaded:Bool = false // первичная загрузка данных таблицы
	private var refreshControl: UIRefreshControl!
	
	internal var locationManager:CLLocationManager!
	private let prefferedMapSize:CGSize	= CGSize(width: 400, height: 300) // желаемые размеры гео-сообщения (скорее пропорции)
	static let prefferedMapScale:Double = 10000 // метров в одной клетке
	internal var myCurrentPlace:CLLocation!
	
	// оптимазация (подгрузка сообщений)
	private let maxMesOnPrimaryLoad:UInt = 25
	private let maxMessagesPerUpdate:UInt = 25
	private var lastKey:String!
	private var globalPath:DatabaseReference! 		// ссылка на список сообщений
	private var allMessagesKeyList = [String]()
	private var allFetched:Bool = false 			// флаг, что все сообщения диалога получены
	private lazy var trancheCount:UInt = maxMessagesPerUpdate			 	// сколько сообщений ожидается получить при вторичной подгрузке
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override func viewDidLoad() {
		super.viewDidLoad()

		setupGeo()
		
		let buttonImg = UIImage(named: "bttn_map_pin")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: buttonImg, style: .plain, target: self, action: #selector(onLocationClick))
		
		let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
		layout?.minimumLineSpacing = 12 // расстояние сверху и снизу ячеек (по дефолту = 12)
		// layout?.headerReferenceSize = CGSize(width: 150, height: 25)
		
		// вставляем поля чтоб чат не соприкосался сверху и снизу
		collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		collectionView?.alwaysBounceVertical = true
		collectionView?.backgroundColor = .white
		
		collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cID.cell_ID)
		collectionView?.register(Video_Cell.self, forCellWithReuseIdentifier: cID.cell_ID_video)
		collectionView?.register(Map_Cell.self, forCellWithReuseIdentifier: cID.cell_ID_map)
		collectionView?.register(Image_Cell.self, forCellWithReuseIdentifier: cID.cell_ID_image)
		collectionView?.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReusableView)
		
		// поведение клавиатуры при скроллинге
		collectionView?.keyboardDismissMode = .interactive
		
		// запускаем индикацию загрузки (в виде UIRefreshControl) вручную
		refreshControl = UIRefreshControl()
		// refreshControl.attributedTitle = NSAttributedString(string: "Загрузка данных...")
		collectionView?.refreshControl = refreshControl
		refreshControl.beginRefreshing()
		collectionView!.setContentOffset(CGPoint(x: 0, y: collectionView!.contentOffset.y - (refreshControl.frame.size.height)), animated: false)
		refreshControl.addTarget(self, action: #selector(loadOldMessages), for: UIControlEvents.valueChanged)
		
		// слушатель на тап по фону сообщений
		collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChatBackingClick)))
		// прослушиватели клавы
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
	}
	
	
	
	/// прицепляем "аксессуар" в виде вьюшки на клавиатуру
	override var inputAccessoryView: UIView? {
		get {
			return growingInputView
		}
	}
	override var canBecomeFirstResponder: Bool {
		return true // без этого не отображается growingInputView
	}
	
	
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		// убиваем слушателя базы
		if !flag{
			NotificationCenter.default.removeObserver(self) // иначе при логауте будет ругатся, да и ни к чему хорошему это не приведет
			disposeVar1?.0.removeObserver(withHandle: disposeVar1.1)
			disposeVar2?.0.removeObserver(withHandle: disposeVar2.1)
			disposeVar1 = nil
			disposeVar2 = nil
		}
		
		// перебираем все видимые ячейки, на предмет проигрывания вних видео
		guard let cells = collectionView?.visibleCells as? [ChatMessageCell] else { return }
		cells.forEach {
			(cell) in
			if cell.isKind(of: Video_Cell.self){
				let nCell = cell as! Video_Cell
				if nCell.isPlaying{
					print("Останавливаем воспроизведение!")
					nCell.removePlayObserver()
					nCell.player?.pause()
					nCell.playerLayer?.removeFromSuperlayer()
				}
			}
		}
	}
	
	
	
	/// переопеределяем констрайнты при каждом повороте экрана (на некоторых моделях телефонов если не сделать - будет залазить/вылазить справа весь контент скролвьюшки)
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		collectionView?.collectionViewLayout.invalidateLayout()
		
		// в режиме просмотра картинки прячем growingInputView, т.к. по непонятной причине оно появляется
		if (startingFrame != nil){
			growingInputView.isHidden = true
		}
		else{
			collectionView?.reloadData()
		}
	}
	

	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataArray[section].count
	}
	
	
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentOffset = scrollView.contentOffset.y;
		// let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
		//		let dif = currentOffset - maximumOffset
		//		print("currentOffset = \(currentOffset)")
		//		print("maximumOffset = \(maximumOffset)")
		//if (currentOffset <= 0) {
		// 	 print("скрол остановился вверху...")
		//}
	}
	
	
	// когда тапаешь по верху экрана (фактически по времени)
	override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return true
	}
		
	
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if indexPath.item == 0 && primaryDataloaded{
		//	print("начало списка...")
		}
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		var cell:ChatMessageCell!
		let message = dataArray[indexPath.section][indexPath.item]
		
		if message.videoUrl != nil{
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: cID.cell_ID_video, for: indexPath) as! Video_Cell
		}
		else if message.geo_lat != nil{
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: cID.cell_ID_map, for: indexPath) as! Map_Cell
		}
		else if message.imageUrl != nil{
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: cID.cell_ID_image, for: indexPath) as! Image_Cell
		}
		else {
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: cID.cell_ID, for: indexPath) as! ChatMessageCell
		}
		
		cell.tag = indexPath.item
		cell.setupCell(linkToParent: self, message: message, indexPath: indexPath)
		
		return cell
	}
	
	
	

	
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var hei:CGFloat = 80
		
		let message = dataArray[indexPath.section][indexPath.item]
		
		// получаем ожидаемую высоту
		if let text = message.text {
			hei = estimatedFrameForText(text: text).height + 20 + 10 //(10 - для времени)
		}
		else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
			// h1/w1 = h2/w2  ->  h1 = h2/w2 * w1
			let w1:CGFloat = CGFloat(UIScreen.main.bounds.width * 2/3)
			hei = (CGFloat(imageHeight) / CGFloat(imageWidth) * w1)
		}
		else if message.geo_lat != nil {
			let w1:CGFloat = CGFloat(UIScreen.main.bounds.width * 3/4)
			hei = (CGFloat(prefferedMapSize.height) / CGFloat(prefferedMapSize.width) * w1)
		}
		
		return CGSize(width: UIScreen.main.bounds.width, height: hei)
	}
	
	
	
	//**********************
	//  Настраиваем секции *
	//**********************
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: 150, height: 45)
	}
	
	/// вьюшка для хэдера в колекшнвью (сюда не будет заходить если не установить значение  для layout?.headerReferenceSize)
	/// или определить верхнюю ф-цию
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		if kind == UICollectionElementKindSectionHeader {
			let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReusableView, for: indexPath) as! SectionHeaderView
			
			headerView.title.text = stringedTimes[indexPath.section]
			return headerView
		}
		// else if kind == UICollectionElementKindSectionFooter { }
		
		fatalError()
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return dataArray.count
	}
	
	//********************
	
	


	
	/// подсчет ожидаемых размеров текстового поля
	public func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: UIScreen.main.bounds.width * 2/3, height: .infinity)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	


	
	
	/// первичное получение сообощений с БД + добавляем слушатель на новые
	private func observeMessages(){

		guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else { return }
		
		let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toID) // ссылка на список сообщений
		var allCount:UInt = 0
		var curCount:UInt = 0
		globalPath = userMessagesRef
		
		userMessagesRef.observeSingleEvent(of: .value) {		// ****(1) получение списка всех сообщений юзера
			
			(snapshot) in
			allCount = min(snapshot.childrenCount, self.maxMesOnPrimaryLoad)
			if snapshot.childrenCount <= self.maxMesOnPrimaryLoad {
				self.allFetched = true
			}
			// преобразовываем список сообщений в массив и сохраняем для дальнейших подрузок
			if let allMessagesKeyList = snapshot.children.allObjects as? [DataSnapshot]{
				self.allMessagesKeyList = Calculations.extractKeysToArray(snapshot: allMessagesKeyList)
			}
			
			// если нет сообщений или их немного
			if allCount == 0 || allCount == self.allMessagesKeyList.count {
				self.collectionView?.refreshControl?.endRefreshing()
				self.collectionView?.refreshControl = nil
				self.allFetched = true
			}


			let tempValue = allCount == 0 ? 1 : allCount // нельзя отправлять запрос с toLast = 0
			
			let handler = userMessagesRef
				.queryLimited(toLast: tempValue)
				.observe(.childAdded, with: { 		// ****(2) перебор каждого ключа сообщения + дальнейшее прослушивание на новые сообщ.
				
				(snapshot) in
				let messagesRef = Database.database().reference().child("messages").child(snapshot.key) // ссылка на сами сообщения
				
				messagesRef.observeSingleEvent(of: .value, with: { //****(3) получение данных конкретного сообщения
					(snapshot) in
					curCount += 1
					if (curCount == 1 && self.lastKey == nil){
						self.lastKey = snapshot.key // сохраняем ключ первого из последних 5 сообщ.
					}
					
					guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
					
					let message = Message(dictionary: dictionary)
					// message.setValuesForKeys(dictionary)
					self.messages.append(message)
					
					//  обновляем таблицу только после получения всех сообщений и последюущих (если будут)
					if curCount >= allCount {
						self.updateCollectionView()
					}
			
				}, withCancel: nil)
				
			}, withCancel: nil)
			
			self.disposeVar1 = (userMessagesRef, handler)
		}
	}

	
	
	
	/// пересчитываем последний ключ базы, с которого начинать подгружать более раннее сообщения
	private func recountLastKey(currentKey:String) -> String? {
		
		if let currentPosition = allMessagesKeyList.index(of: currentKey){
			var startPosition = currentPosition - 1
			
			// если это будет последняя подгрузка (0 тут никогда не будет)
			if startPosition <= maxMessagesPerUpdate{
				allFetched = true
				trancheCount = UInt(startPosition) + 1
				collectionView?.refreshControl?.endRefreshing()
				collectionView?.refreshControl = nil
			}
			if startPosition < 0 {
				startPosition += 1
				allFetched = true
			}
			return allMessagesKeyList[startPosition]
		}
		return nil
	}
	

	
	
	/// вторичное получение сообщений (подгрузка давних)
	@objc private func loadOldMessages(){
		
		if allFetched {
			collectionView?.refreshControl?.endRefreshing()
			return
		}
		var curCount:UInt = 0
		var tempArr = [Message]()
		lastKey = recountLastKey(currentKey: lastKey)
		
		
		let handler = globalPath
			.queryOrderedByKey()
			.queryEnding(atValue: lastKey)
			.queryLimited(toLast: trancheCount)
			.observe(.childAdded, with: {		// (2) перебор каждого ключа сообщения
			
			(snapshot) in
			let messagesRef = Database.database().reference().child("messages").child(snapshot.key) // ссылка на сами сообщения
			
			messagesRef.observeSingleEvent(of: .value, with: { 						// (3) получение данных конкретного сообщения
				(snapshot) in
				curCount += 1
				if (curCount == 1){
					self.lastKey = snapshot.key // сохраняем ключ первого из последних N сообщ.
				}
				
				guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
				let message = Message(dictionary: dictionary)
				tempArr.append(message)
				
				//  обновляем таблицу только после получения всех сообщений и последюущих (если будут)
				if curCount >= self.trancheCount {
					self.messages = tempArr + self.messages
					self.updateCollectionView(prependToBegin: true)
				}
				
			}, withCancel: nil)
			
		}, withCancel: nil)
		disposeVar2 = (globalPath, handler)
	}
	
	
	
	

	
	
	/// умная обновлялка collectionView и его источника
	// prependToBegin = true подгружаем начальные (давние) сообщения
	private func updateCollectionView(prependToBegin:Bool = false){
		
		// если это загрузка всего диалога или подгрузка старых вначало
		if !primaryDataloaded || prependToBegin {
			DispatchQueue.main.async {
				self.smartSort()
				self.collectionView?.refreshControl?.endRefreshing()
				self.collectionView?.reloadData()
				if !prependToBegin {
					self.collectionView?.scrollToLast(animated: false)
				}
				self.primaryDataloaded = true
			}
		}
		// если это обновление путем добавления сообщений
		else {
			// обновляем источник таблицы
			guard !messages.isEmpty else { return }
			dataArray[dataArray.count - 1].append(messages.last!)
			
			// обновляем саму таблицу
			collectionView?.performBatchUpdates({
				let indexPath = IndexPath(item: dataArray[dataArray.count - 1].count - 1, section: dataArray.count - 1)
				collectionView?.insertItems(at: [indexPath])
			}, completion: {
				(bool) in
				self.collectionView?.scrollToLast(animated: true)
			})
		}
		print("Обновили чат")
	}
	
	
	
	
	
	/// создание 2-х мерного массива для сообщений и их секций
	private func smartSort(){
		
		dataArray.removeAll()
		stringedTimes.removeAll()
		
		// собираем все даты в массив
		let dataList = messages.map{$0.timestamp!} 	// массив timeStamp'ов 16655454
		
		// создаем массив конвертированных дат (без повтора)
		for value in dataList {
			let dateString = gatheringData(seconds: TimeInterval(truncating: value))
			if !stringedTimes.contains(dateString){
				stringedTimes.append(dateString)
				dataArray.append([])
			}
		}
		
		// заполняем массив массивов юзеров, согласно алфавита
		for element in messages {
			let temp = gatheringData(seconds: TimeInterval(truncating: element.timestamp!))
			let index = stringedTimes.index(of: temp)
			dataArray[index!].append(element)
		}
	}
	
	
	
	
	/// преобразования даты для секций колекшнвью
	private func gatheringData(seconds:TimeInterval) -> String{
		
		let convertedDate = Date(timeIntervalSince1970: seconds)
		let dateFormater = DateFormatter()
		
		// сегодня
		if Calendar.current.isDateInToday(convertedDate){
			return "сегодня"
		}
		// вчера
		else if Calendar.current.isDateInYesterday(convertedDate){
			return "вчера"
		}
		// на этой неделе (пятница)
		else if seconds + Double(604800) >= NSDate().timeIntervalSince1970 {
			var weekDayNum = Calendar.current.component(.weekday, from: convertedDate) - 1 // возвращает дни, начиная с 1
			if weekDayNum == 7 {
				weekDayNum = 0 // т.к. Вс - это 0-вой элемент массива
			}
			let weekDay = dateFormater.weekdaySymbols[weekDayNum]
			return weekDay
		}
		// более недели назад (03 Окт)
		else {
			dateFormater.dateFormat = "dd"
			let numDay = dateFormater.string(from: convertedDate)
			var month = dateFormater.shortMonthSymbols[Calendar.current.component(.month, from: convertedDate) - 1]
			if month.last == "."{
				month = String(month.dropLast())
			}
			return numDay + " " + month
		}
	}
	
	
	
	
	@objc private func onChatBackingClick(){
		growingInputView.inputTextField.resignFirstResponder()
	}
	
	
	
	@objc private func keyboardDidShow(notif: Notification){
		
		if let keyboardFrame = (notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
			// при повороте экрана происходит ложное срабатывание - клава не выезжает (но высота ее = 50), потому проверяем ее размер
			if keyboardFrame.height > 100 {
				collectionView?.scrollToLast(animated: true)
			}
		}
	}
	
	
	
	
	// клик на булавку (отправить геолокацию)
	@objc private func onLocationClick(){
		checkLocationAuthorization()
	}
	
	
	
	
	
	/// клик на картинку (переслать фотку)
	@objc public func onUploadClick(){
		
		let imagePickerController = UIImagePickerController()
		
		imagePickerController.allowsEditing = true
		imagePickerController.delegate = self
		// разрешаем выбирать видеофайлы из библиотеки
		imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
		
		flag = true
		present(imagePickerController, animated: true, completion: nil)
	}
	
	
	
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		var permission:Bool = true
		flag = false
		
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
		flag = true
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
	
	
	
	
	@objc public func onSendClick(){
		if growingInputView.inputTextField.text == "" || growingInputView.inputTextField.text == " " { return }
		
		let properties:[String:Any] = [
			"text" :growingInputView.inputTextField.text!
		]
		sendMessage_with_Properties(properties: properties)
		
		growingInputView.inputTextField.text = nil
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
	
	
	
	
	///  присоединяем к сообщению required поля и отправляем в БД
	internal func sendMessage_with_Properties(properties: [String:Any]){
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
				self.growingInputView.alpha = 0 // вьюшка ввода сообщения
				
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
				self.growingInputView.alpha = 1
				tapedImageView.layer.cornerRadius = 12
				tapedImageView.clipsToBounds = true
			}, completion: {
				(completed:Bool) in
				tapedImageView.removeFromSuperview()
				self.blackBackgroundView = nil
				self.blackBackgroundView?.removeFromSuperview()
				self.originalImageView?.isHidden = false
				self.growingInputView.isHidden = false
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
	
	

	
	
	
}















