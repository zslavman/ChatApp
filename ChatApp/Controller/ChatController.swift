//
//  ChatController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 06.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//


import UIKit
import Firebase
import CoreLocation

import AVKit

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	public var user: ChatUser? {
		didSet {
			if let userName = user?.name {
				drawCustomTitleView(name: userName)
			}
			fetchMessages()
			checkDialogerStatus()
		}
	}
	internal lazy var growingInputView: InputAccessory = {
		let inputView = InputAccessory(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
		inputView.chatController = self
		
		return inputView
	}()
	private lazy var scrollingDownBttn: UIButton = {
		let bttn = UIButton(type: UIButton.ButtonType.system)
		bttn.translatesAutoresizingMaskIntoConstraints = false
		let img = UIImage(named: "bttn_down")!.withRenderingMode(.alwaysOriginal)
		bttn.setImage(img, for: UIControl.State.normal)
		bttn.layer.shadowOffset = CGSize(width: 0, height: 3)
		bttn.layer.shadowRadius = 3
		bttn.layer.shadowOpacity = 0.3
		bttn.alpha = 0
		bttn.tintColor = UIConfig.mainThemeColor
		bttn.addTarget(self, action: #selector(onScrollingDownClick), for: UIControl.Event.touchUpInside)
		return bttn
	}()
	struct cID {
		static let cell_ID: String 			= "cell_ID"
		static let cell_ID_video: String 	= "cell_ID_video"
		static let cell_ID_map: String 		= "cell_ID_map"
		static let cell_ID_image: String 	= "cell_ID_image"
	}
	private let headerReusableView:String 	= "sectionHeader"
	
	internal var startingFrame: CGRect?
	internal var blackBackgroundView: UIView?
	internal var originalImageView: UIView?
	internal var orig: UIView?
	
	private var messages: [Message] = []
	private var containerViewBottomAnchor: NSLayoutConstraint?
	private var disposeVar1: (DatabaseReference, UInt)!
	private var disposeVar2: (DatabaseReference, UInt)!
	internal var selectMediaContentOpened: Bool = false // флаг, что открыто окно выбора картинки (false - слушатель удаляется)
	private var dataArray = [[Message]]() 	// двумерный массив сообщений в секциях
	private var stringedTimes = [String]()	// массив конвертированных в строку дат сообщений (для заглавьяь секций)
	
	private var primaryDataloaded: Bool = false // первичная загрузка данных таблицы
	private var refreshControl: UIRefreshControl!
	
	internal var locationManager: CLLocationManager!
	private let prefferedMapSize: CGSize	= CGSize(width: 400, height: 300) // желаемые размеры гео-сообщения (скорее пропорции)
	static let prefferedMapScale: Double = 10000 // метров в одной клетке
	internal var myCurrentPlace: CLLocation!
	
	// оптимазация (подгрузка сообщений)
	private let maxMesOnPrimaryLoad: UInt = UserDefFlags.limit_mess
	private let maxMessagesPerUpdate: UInt = 25
	private var lastKey: String!						// точка отсчета подгрузки более старых сообщений
	private var globalPath: DatabaseReference! 		// ссылка на список сообщений
	private var allMessagesKeyList = [String]()
	private var allFetched: Bool = false 			// флаг, что все сообщения диалога получены
	private lazy var trancheCount: UInt = maxMessagesPerUpdate // сколько сообщений ожидается получить при вторичной подгрузке
	
	private var statusListeners = [UInt: DatabaseReference]() 	// для диспоза слушателей
	private let delayBeforeReadUnreaded: Double = 1.2 // задержка перед тем как входящие непрочитанные станут прочитанными
	private var visitHeightAnchor: NSLayoutConstraint!
	private var lastVisitLable: UILabel!
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override func viewDidLoad() {
		super.viewDidLoad()
		setupGeo()
		
		navigationController?.navigationBar.items![0].title = dict[20]![LANG] // Назад
		
		let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
		layout?.minimumLineSpacing = 0 // расстояние сверху и снизу ячеек (по дефолту = 12)
		// layout?.headerReferenceSize = CGSize(width: 150, height: 25)
		
		// вставляем поля отделяющие чат сверху и снизу
		collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		collectionView?.alwaysBounceVertical = true
		collectionView?.backgroundColor = .white
		
		collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cID.cell_ID)
		collectionView?.register(Video_Cell.self, forCellWithReuseIdentifier: cID.cell_ID_video)
		collectionView?.register(Map_Cell.self, forCellWithReuseIdentifier: cID.cell_ID_map)
		collectionView?.register(Image_Cell.self, forCellWithReuseIdentifier: cID.cell_ID_image)
		collectionView?.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReusableView)
		
		// поведение клавиатуры при скроллинге
		collectionView?.keyboardDismissMode = .interactive
		
		// запускаем индикацию загрузки (в виде UIRefreshControl) вручную
		showRefreshControl()
		
		// слушатель на тап по фону сообщений
		collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChatBackingClick)))
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
		
		view.addSubview(scrollingDownBttn)
		NSLayoutConstraint.activate([
			scrollingDownBttn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
			scrollingDownBttn.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -60),
			scrollingDownBttn.widthAnchor.constraint(equalToConstant: 45),
			scrollingDownBttn.heightAnchor.constraint(equalToConstant: 45)
		])
		// скрываем родную навбаровскую кнопку назад ибо некрасиво
		let tp = UIBarButtonItem(image: UIImage(named: "bttn_back"), style: .plain, target: self, action: #selector(goBack))
		navigationItem.setLeftBarButton(tp, animated: false)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(dialogerDidChangeStatus(_:)),
											   name: .dialogerDidChangeStatus,
											   object: nil)
	}
	

	
	
	/// цепляем "аксессуар" в виде вьюшки на клавиатуру
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
		// kill database listeners
		if !selectMediaContentOpened {
			NotificationCenter.default.removeObserver(self) // otherwise will have issue on logout
			disposeVar1?.0.removeObserver(withHandle: disposeVar1.1)
			disposeVar2?.0.removeObserver(withHandle: disposeVar2.1)
			disposeVar1 = nil
			disposeVar2 = nil
		}
		// collect all visible cells, stop video it if they have it
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
		for (key, ref) in statusListeners {
			ref.removeObserver(withHandle: key)
		}
	}
	
	
	/// переопеределяем констрайнты при каждом повороте экрана (на некоторых моделях телефонов если не сделать - будет залазить/вылазить справа весь контент скролвьюшки)
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		collectionView?.collectionViewLayout.invalidateLayout()
		// в режиме просмотра картинки прячем growingInputView, т.к. по непонятной причине оно появляется
		if (startingFrame != nil) {
			growingInputView.isHidden = true
		}
		else {
			collectionView?.reloadData()
		}
	}
	

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataArray[section].count
	}
	
	
	
	// когда тапаешь по верху экрана (фактически по времени)
	override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return true
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
			cell = (collectionView.dequeueReusableCell(withReuseIdentifier: cID.cell_ID, for: indexPath) as! ChatMessageCell)
		}
		cell.tag = indexPath.item
		cell.setupCell(linkToParent: self, message: message, indexPath: indexPath)
		
		return cell
	}
	
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// высчитываем появление кнопки "Вниз"
		let currentOffset = scrollView.contentOffset.y
		let frameHeight = scrollView.frame.size.height
		let contentHeight = scrollView.contentSize.height - frameHeight
		
		if currentOffset <= contentHeight - 190 {
			UIView.animate(withDuration: 0.3) {
				self.scrollingDownBttn.alpha = 1
			}
		}
		else {
			UIView.animate(withDuration: 0.3) {
				self.scrollingDownBttn.alpha = 0
			}
		}
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var hei:CGFloat = 80
		
		let message = dataArray[indexPath.section][indexPath.item]
		
		// получаем ожидаемую высоту
		if let text = message.text {
			hei = SUtils.estimatedFrameForText(text: text).height + 20 + 10 + 12 //(10 - для времени, 12 - для простора)
		}
		else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
			// h1/w1 = h2/w2  ->  h1 = h2/w2 * w1
			let w1:CGFloat = CGFloat(UIScreen.main.bounds.width * 2/3)
			hei = (CGFloat(imageHeight) / CGFloat(imageWidth) * w1) + ChatMessageCell.paddingTop * 2
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
		
		if kind == UICollectionView.elementKindSectionHeader {
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
	
	
	// MARK: получение сообщений
	/// первичное получение сообощений с БД + добавляем слушатель на новые
	private func fetchMessages() {
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
			// преобразовываем список сообщений в массив и сохраняем для дальнейших подгрузок
			if let allMessagesKeyList = snapshot.children.allObjects as? [DataSnapshot]{
				self.allMessagesKeyList = SUtils.extractKeysToArray(snapshot: allMessagesKeyList)
			}
			// если нет сообщений или их немного
			if allCount == 0 || allCount == self.allMessagesKeyList.count {
				self.collectionView?.refreshControl?.endRefreshing()
				self.collectionView?.refreshControl = nil
				self.allFetched = true
				// автоматический выезд клавиатуры
				if allCount == 0 {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
						self.growingInputView.inputTextField.becomeFirstResponder()
					})
				}
			}
			let tempValue = allCount == 0 ? 1 : allCount // нельзя отправлять запрос с toLast = 0
			
			let handler = userMessagesRef
				.queryLimited(toLast: tempValue)
				.observe(.childAdded, with: { 		// ****(2) перебор каждого ключа сообщения + дальнейшее прослушивание на новые сообщ.
				(snapshot) in
				let messagesRef = Database.database().reference().child("messages").child(snapshot.key) // ссылка на сами сообщения
				let savedSnap = snapshot // сохраняем снапшот, а ниже проверим если это сообщение для нас, то ...
					
				messagesRef.observeSingleEvent(of: .value, with: { //****(3) получение данных конкретного сообщения
					(snapshot) in
					curCount += 1
					if (curCount == 1 && self.lastKey == nil){
						self.lastKey = snapshot.key // сохраняем ключ первого из последних N сообщ. (дальнейшая подгрузка будет с этого места)
					}
					
					guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
					let message = Message(dictionary: dictionary)
					
					// если это исходящее сообщ., и оно не прочтено - добавляем слушатели на прочтение
					if message.fromID == uid && !message.readStatus!{
						let refStatus = Database.database().reference().child("messages").child(snapshot.key)
						let number = refStatus.observe(.value, with: {
							(snapShot) in
							self.readStatusUpdate(snapshot: snapShot)
						})
						self.statusListeners[number] = refStatus
					}
					
					// если это входящее сообщ., то отправляем ответ что мы его прочли (только в ветку собеседника!)
					else if message.fromID != uid{
						// обновляем статус о прочтении в списке сообщений (в ветке собеседника)
						Database.database().reference().child("user-messages").child(message.fromID!).child(uid).child(savedSnap.key).setValue(1)
						// обновляем статус о прочтении в самом сообщении
						Database.database().reference().child("messages").child(snapshot.key).child("readStatus").setValue(true)
						// message.readStatus = true
					}
					self.messages.append(message)
					
					//  обновляем таблицу только после получения всех сообщений и последюущих (если будут)
					if curCount >= allCount {
						if curCount == allCount{
							// во избежании накопления, полностью убираем инфу о непрочитанных
							let unreadRef = Database.database().reference().child("unread-messages-foreach").child(uid).child(toID)
							unreadRef.removeValue()
						}
						self.updateCollectionView()
					}
				}, withCancel: nil)
			}, withCancel: nil)
			self.disposeVar1 = (userMessagesRef, handler)
		}
	}

	
	/// обновление статуса исходящего сообщения + обновление источника
	private func readStatusUpdate(snapshot:DataSnapshot) { // сюда зайдет только после первичной загрузки
		// проверяем, чтоб флаг readStatus == true (при установке слушателя тоже зайдет, когда readStatus == false)
		guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
		let tempMess = Message(dictionary: dictionary)
		guard tempMess.readStatus! else { return }
		
		// находим слушателя в словаре и удаляем
		let listenerRef = Database.database().reference().child("messages").child(snapshot.key)
		for (element) in statusListeners{
			if element.value.description() == listenerRef.description{
				element.value.removeObserver(withHandle: element.key)
				statusListeners.removeValue(forKey: element.key)
			}
		}
		// обновляем источники
		messages.forEach {
			(mes:Message) in
			if mes.self_ID == tempMess.self_ID! {
				mes.readStatus = true
			}
		}
		dataArray.forEach {
			(mes:[Message]) in
			mes.forEach({
				(insideMes:Message) in
				if insideMes.self_ID == tempMess.self_ID! {
					insideMes.readStatus = true
				}
			})
		}
		// проверяем, нет ли в видимых ячейках сообщения со снапшотом snapshot
		// так не обновляются ячейки, которые на 2 выше и ниже выдимых
//		collectionView?.visibleCells.forEach({
//			(cell) in
//			if (cell as! ChatMessageCell).message?.self_ID == tempMess.self_ID!{
//				(cell as! ChatMessageCell).setToGreen()
//			}
//		})
		collectionView?.reloadData()
	}
	
	
	/// задержанная (только 1-й раз) анимация прочтения входящих сообщений (если таковы будут)
	private func delayedReadStatusUpdate() {
		var count:Int = 0
		// обновляем источники
		messages.forEach {
			(mes:Message) in
			if !mes.readStatus! && mes.toID == Auth.auth().currentUser?.uid {
				mes.readStatus = true
				count += 1
			}
		}
		dataArray.forEach {
			(mes:[Message]) in
			mes.forEach({
				(insideMes:Message) in
				if !insideMes.readStatus! && insideMes.toID == Auth.auth().currentUser?.uid {
					insideMes.readStatus = true
				}
			})
		}
		if count > 0 {
			collectionView?.reloadData()
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
	@objc private func loadOldMessages() {
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
			
			messagesRef.observeSingleEvent(of: .value, with: { 			// (3) получение данных конкретного сообщения
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
	/// prependToBegin = true подгружаем начальные (давние) сообщения
	private func updateCollectionView(prependToBegin:Bool = false) {
		// если это загрузка всего диалога или подгрузка старых в начало
		if !primaryDataloaded || prependToBegin {
			DispatchQueue.main.async {
				self.smartSort()
				self.collectionView?.refreshControl?.endRefreshing()
				self.collectionView?.reloadData()
				if !prependToBegin {
					self.collectionView?.scrollToLast(animated: false)
					DispatchQueue.main.asyncAfter(deadline: .now() + self.delayBeforeReadUnreaded, execute: {
						self.delayedReadStatusUpdate()
					})
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
			let indexPath = IndexPath(item: dataArray[dataArray.count - 1].count - 1, section: dataArray.count - 1)
			
			collectionView?.performBatchUpdates({
				collectionView?.insertItems(at: [indexPath])
			}, completion: {
				(bool) in
				self.collectionView?.scrollToLast(animated: true)
				self.delayedReadStatusUpdate()
			})
		}
		print("Обновили чат")
	}
	
	
	
	/// автоматич. запуск showRefreshControl, аля индикация загрузки
	private func showRefreshControl() {
		refreshControl = UIRefreshControl()
		// refreshControl.attributedTitle = NSAttributedString(string: "Загрузка данных...")
		collectionView?.refreshControl = refreshControl
		refreshControl.beginRefreshing()
		collectionView!.setContentOffset(CGPoint(x: 0, y: collectionView!.contentOffset.y - (refreshControl.frame.size.height)), animated: false)
		refreshControl.addTarget(self, action: #selector(loadOldMessages), for: UIControl.Event.valueChanged)
	}
	
	
	
	/// создание 2-х мерного массива для сообщений и их секций
	private func smartSort() {
		dataArray.removeAll()
		stringedTimes.removeAll()
		// собираем все даты в массив
		let dataList = messages.map{$0.timestamp!} 	// массив timeStamp'ов 16655454
		
		// создаем массив конвертированных дат (без повтора)
		for value in dataList {
			let dateString = SUtils.gatheringData(seconds: TimeInterval(truncating: value))
			if !stringedTimes.contains(dateString){
				stringedTimes.append(dateString)
				dataArray.append([])
			}
		}
		// заполняем массив массивов юзеров, согласно алфавита
		for element in messages {
			let temp = SUtils.gatheringData(seconds: TimeInterval(truncating: element.timestamp!))
			let index = stringedTimes.index(of: temp)
			dataArray[index!].append(element)
		}
	}
	
	
	@objc private func onChatBackingClick() {
		growingInputView.inputTextField.resignFirstResponder()
		// UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
	}
	
	
	@objc private func keyboardDidShow(notif: Notification) {
		if let keyboardFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
			// при повороте экрана происходит ложное срабатывание - клава не выезжает (но высота ее = 50), потому проверяем ее размер
			if keyboardFrame.height > 100 {
				collectionView?.scrollToLast(animated: true)
			}
		}
	}
	
	
	@objc private func onScrollingDownClick() {
		collectionView?.scrollToLast(animated: true)
	}
	
	
	@objc private func goBack() {
		self.navigationController?.popViewController(animated: true)
	}
	
	
	@objc public func onSendClick() {
		if growingInputView.inputTextField.text == "" { return }
		let filtered = growingInputView.inputTextField.text!.filter{!" ".contains($0)} // отфильтровываем пробелы
		if filtered.count == 0 { return }
		
		let properties:[String:Any] = [
			"text" :growingInputView.inputTextField.text!
		]
		sendMessage_with_Properties(properties: properties)
		growingInputView.inputTextField.text = nil
	}
	
	

	// MARK: отправка сообщения
	///  присоединяем к сообщению required поля и отправляем в БД
	internal func sendMessage_with_Properties(properties: [String:Any]) {
		let ref = Database.database().reference().child("messages")
		// генерация псевдо-рандомных ключей сообщения chatapp-2222e.firebaseio.com/messages/-LQe7kjoAJkrVNzOjERM
		let childRef = ref.childByAutoId()
		
		let toID = user!.id!
		let fromID = Auth.auth().currentUser!.uid
		let timestamp: Int = Int(NSDate().timeIntervalSince1970)
		
		let self_ID = childRef.description().split(separator: "/").last!

		var values:[String:Any] = [
			"toID"			:toID,
			"fromID"		:fromID,
			"timestamp"		:timestamp,
			"readStatus"	:false,
			"self_ID"		:self_ID
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
			
			// создаем структуру цепочки сообщений ДЛЯ определенного пользователя (тут будут лишь ID сообщений)
			let senderRef = messRef.child(fromID).child(toID)
			let messageID = childRef.key!
			senderRef.updateChildValues([messageID: 0])
			
			// создаем структуру цепочки сообщений ОТ определенного пользователя (тут будут лишь ID сообщений)
			let recipientRef = messRef.child(toID).child(fromID)
			recipientRef.updateChildValues([messageID: 0])
			// тоже самое записываем и в ветку с непрочтенными
			let unreadRef = Database.database().reference().child("unread-messages-foreach").child(toID).child(fromID)
			unreadRef.updateChildValues([messageID: 0])
		}
		if let fcmToken = user?.fcmToken {
			let messagesController = tabBarController?.viewControllers![0].children.first as! MessagesController
			let name = messagesController.owner.name
			
			var body: String = ""
			if (properties["videoUrl"] as? String) != nil {
				body = dict[29]![LANG] // [видео]
			}
			else if (properties["imageUrl"] as? String) != nil {
				body = dict[30]![LANG] // [картинка]
			}
			else if (properties["geo_lat"] as? NSNumber) != nil {
				body = dict[50]![LANG] // [геокоординаты]
			}
			else {
				body = properties["text"] as! String
			}
			let fromID = MessagesController.shared.owner.id!
			APIServices.sendNotification(taskDictionary: [
				"to" 	: fcmToken,
				"title"	: name!,
				"body"	: body,
				"fromID": fromID
			])
		}
	}
	
	
	private func drawCustomTitleView(name: String) {
		let nameLabel = UILabel()
		nameLabel.text = name
		nameLabel.textColor = UIColor.white
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.minimumScaleFactor = 0.9
		nameLabel.sizeToFit()
		
		lastVisitLable = UILabel()
		lastVisitLable.textColor = UIColor.white.withAlphaComponent(0.7)
		lastVisitLable.adjustsFontSizeToFitWidth = true
		lastVisitLable.sizeToFit()
		lastVisitLable.font = UIFont.systemFont(ofSize: 12)
		
		visitHeightAnchor = lastVisitLable.heightAnchor.constraint(equalToConstant: 15)
		visitHeightAnchor.isActive = true
		visitHeightAnchor.constant = 0
		
		let stackView = UIStackView(arrangedSubviews: [nameLabel, lastVisitLable])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 0
		stackView.backgroundColor = UIColor.orange
		navigationItem.titleView = stackView
	}

	

	@objc private func dialogerDidChangeStatus(_ notification: NSNotification) {
		if let dict = notification.userInfo as NSDictionary? {
			guard let isDialogerOnline = dict["dStatus"] as? Bool else { return }
			
			if let user = self.user {
				user.isOnline = isDialogerOnline
				print("Call dialogerDidChangeStatus")
				checkDialogerStatus()
			}
		}
	}
	
	
	private func setLastVisit(dateInfo: String) {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3, animations: {
				self.visitHeightAnchor.constant = 15
				self.navigationItem.titleView!.layoutIfNeeded()
				self.lastVisitLable.text = dateInfo
			})
		}
	}
	
	
	private func checkDialogerStatus() {
		guard let user = self.user else { return }
		if user.isOnline {
			setLastVisit(dateInfo: dict[52]![LANG]) // online
			return
		}
		let listenerRef = Database.database().reference().child("users").child(user.id!).child("lastVisit")
		listenerRef.observeSingleEvent(of: .value) {
			[weak self] (snapshot) in
			guard let strongSelf = self else { return }
			guard let lastVisit = snapshot.value as? TimeInterval else { return }
			let lastVisitDate = SUtils.timesAgoDisplay(timeinterval: lastVisit)
			let lastVisitString = dict[51]![LANG] + lastVisitDate // был(а) в сети:
			strongSelf.setLastVisit(dateInfo: lastVisitString)
			print("set LastVisit")
		}
	}
	

	/// воспроизведение видео на нативном плеере в фулскрине
	public func runNativePlayer(videoUrl: URL, currentSeek: CMTime) {
		let player = AVPlayer(url: videoUrl)
		player.currentItem?.seek(to: currentSeek, completionHandler: nil) // устанавливаем время начала воспроизведения
		let vc = AVPlayerViewController()
		vc.player = player
		
		present(vc, animated: true) {
			vc.player?.play()
		}
	}
	
}


extension Notification.Name {
	public static let dialogerDidChangeStatus = Notification.Name("dialogerDidChangeStatus")
}






