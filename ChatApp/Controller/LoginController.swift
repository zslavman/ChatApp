//
//  LoginController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


let default_profile_image:String = "default_profile_image"


class LoginController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
	
	internal var messagesController:MessagesController?

	public lazy var profileImageView: UIImageView = { // если не объявить как lazy то не будет работать UITapGestureRecognizer
		let imageView = UIImageView()
		imageView.image = UIImage(named: default_profile_image)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onProfileClick)))
		imageView.isUserInteractionEnabled = true
//		imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	private let inputsContainerView: UIView = {
		let view_i = UIView()
		view_i.backgroundColor = .white
		view_i.translatesAutoresizingMaskIntoConstraints = false
		view_i.layer.cornerRadius = 8
		view_i.layer.shadowOffset = CGSize(width: 0, height: 3)
		view_i.layer.shadowRadius = 3
		view_i.layer.shadowOpacity = 0.3
		return view_i
	}()
	
	private let loginRegisterBttn :UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		button.layer.cornerRadius = 8
		button.setTitle("Register", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.shadowOffset = CGSize(width: 0, height: 3)
		button.layer.shadowRadius = 3
		button.layer.shadowOpacity = 0.3
		button.layer.shouldRasterize = true
		button.addTarget(self, action: #selector(onGoClick), for: UIControlEvents.touchUpInside)
		return button
	}()
	
	
	internal let nameTF:UITextField = {
		let tf = UITextField()
		tf.placeholder = "Имя"
		tf.backgroundColor = .white
		tf.autocapitalizationType = .words
		tf.autocorrectionType = UITextAutocorrectionType.no
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf.frame.height))
		tf.leftViewMode = .always
		tf.layer.shadowOffset = CGSize(width: 0, height: 3)
		tf.layer.shadowRadius = 3
		tf.layer.shadowOpacity = 0.3
		tf.layer.cornerRadius = 7
		tf.layer.masksToBounds = true
		return tf
	}()
	private let nameSeparator:UIView = {
		let separator = UIView()
		separator.backgroundColor = UIColor.lightGray
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()
	//*********************
	
	internal let emailTF:UITextField = {
		let tf = UITextField()
		tf.placeholder = "Email"
		tf.backgroundColor = .white
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.keyboardType = .emailAddress
		tf.autocorrectionType = .no
		tf.autocapitalizationType = .none
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf.frame.height))
		tf.leftViewMode = .always
		tf.text = "A24@gmail.com" // потом убрать!
		tf.layer.shadowOffset = CGSize(width: 0, height: 3)
		tf.layer.shadowRadius = 3
		tf.layer.shadowOpacity = 0.3
		tf.layer.cornerRadius = 7
		tf.layer.masksToBounds = true
		return tf
	}()
	
	
	internal let passTF:UITextField = {
		let tf = UITextField()
		tf.placeholder = "Пароль"
		tf.backgroundColor = .white
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.isSecureTextEntry = true
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf.frame.height))
		tf.leftViewMode = .always
		tf.text = "111111" // потом убрать!
		tf.layer.shadowOffset = CGSize(width: 0, height: 3)
		tf.layer.shadowRadius = 3
		tf.layer.shadowOpacity = 0.3
		tf.layer.cornerRadius = 7
		tf.layer.masksToBounds = true
		return tf
	}()

	
	
	internal let loginSegmentedControl:UISegmentedControl = {
		let sc = UISegmentedControl(items: ["Login", "Register"])
		sc.translatesAutoresizingMaskIntoConstraints = false
		sc.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		sc.selectedSegmentIndex = 1
		sc.addTarget(self, action: #selector(onSegmentedClick), for: UIControlEvents.valueChanged)
		return sc
	}()
	
	private let helperElement_bottom: UIView = {
		let helper = UIView()
		helper.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
		helper.translatesAutoresizingMaskIntoConstraints = false
		return helper
	}()
	
	private var plus_label: UIImageView = {
		let plus = UIImageView()
		plus.image = UIImage(named: "bttn_plus_green")
		plus.isUserInteractionEnabled = false
		plus.translatesAutoresizingMaskIntoConstraints = false
		plus.layer.shadowOffset = CGSize(width: 0, height: 3)
		plus.layer.shadowRadius = 3
		plus.layer.shadowOpacity = 0.3
		return plus
	}()
	
	internal var selectedImage:UIImage? {
		didSet{
			plus_label.isHidden = true
		}
	}
	
	private var mainStackView:UIStackView!
	private var nameTFHeightAnchor:NSLayoutConstraint?
	
	private var keyboardHeight:CGFloat = 0
	private let defaultConstHeight:CGFloat = -35
	private var baseHeightAnchor:NSLayoutConstraint? // смещение центра основного контейнера по Y
	private var pHeightAnchor:NSLayoutConstraint? // высота фотки
	private var pWidthAnchor:NSLayoutConstraint? // ширина фотки
	
	private var screenSize = CGSize.zero
	internal var waitScreen:WaitScreen?
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		
		collectionView?.alwaysBounceVertical = true
		collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "reuseIdentifier")
		collectionView?.keyboardDismissMode = .interactive
		
		collectionView?.backgroundColor = UIColor(r: 45, g: 127, b: 193)
		
		screenSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
		
		setup_UI()
		
		
		// изначально нужно загружать экран Логина а не Регистрации
		loginSegmentedControl.selectedSegmentIndex = 0
		onSegmentedClick()
		
		nameTF.delegate = self
		emailTF.delegate = self
		passTF.delegate = self
		
		// слушатель на тап по фону сообщений
		collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChatBackingClick)))
		// прослушиватели клавы
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	


	
	
	
	
	private func setup_UI(){
		
		// стейвью для полей ввода
		let inputsStackView = UIStackView(arrangedSubviews: [nameTF, emailTF, passTF])
		inputsStackView.axis 		 = .vertical
		inputsStackView.alignment 	 = .center
		inputsStackView.distribution = .fill
		inputsStackView.spacing 	 = 5
		inputsStackView.translatesAutoresizingMaskIntoConstraints = false
		
		// главный стеквью
		mainStackView = UIStackView(arrangedSubviews: [profileImageView, loginSegmentedControl, inputsStackView, loginRegisterBttn])
		mainStackView.axis 		 	= .vertical
		mainStackView.alignment 	= .center
		mainStackView.distribution 	= .fillProportionally
		mainStackView.spacing 	 	= 20
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		
		mainStackView.addSubview(inputsStackView)
		collectionView?.addSubview(mainStackView)
		
		nameTF.leftAnchor.constraint(equalTo: inputsStackView.leftAnchor).isActive 	= true
		nameTF.rightAnchor.constraint(equalTo: inputsStackView.rightAnchor).isActive = true
		nameTFHeightAnchor = nameTF.heightAnchor.constraint(equalToConstant: 40)
		nameTFHeightAnchor?.isActive = true
		emailTF.leftAnchor.constraint(equalTo: inputsStackView.leftAnchor).isActive = true
		emailTF.rightAnchor.constraint(equalTo: inputsStackView.rightAnchor).isActive = true
		emailTF.heightAnchor.constraint(equalToConstant: 40).isActive = true
		passTF.leftAnchor.constraint(equalTo: inputsStackView.leftAnchor).isActive = true
		passTF.rightAnchor.constraint(equalTo: inputsStackView.rightAnchor).isActive = true
		passTF.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		loginSegmentedControl.widthAnchor.constraint(equalToConstant: 150).isActive = true
		loginSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		loginRegisterBttn.widthAnchor.constraint(equalToConstant: 150).isActive = true
		loginRegisterBttn.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		inputsStackView.leftAnchor.constraint(equalTo: mainStackView.leftAnchor).isActive 	= true
		inputsStackView.rightAnchor.constraint(equalTo: mainStackView.rightAnchor).isActive = true
		
		let const = UIDevice.current.orientation.isPortrait ? defaultConstHeight : 0
		baseHeightAnchor = mainStackView.centerYAnchor.constraint(equalTo: collectionView!.centerYAnchor, constant: const)
		baseHeightAnchor!.isActive = true
		mainStackView.centerXAnchor.constraint(equalTo: collectionView!.centerXAnchor).isActive = true
		mainStackView.widthAnchor.constraint(equalTo: collectionView!.widthAnchor, multiplier: 0.5, constant: 120).isActive = true
		
		// нижний вспомогательный элемент
		collectionView?.addSubview(helperElement_bottom)
		helperElement_bottom.centerXAnchor.constraint(equalTo: (collectionView?.centerXAnchor)!).isActive = true
		helperElement_bottom.topAnchor.constraint(equalTo: loginRegisterBttn.bottomAnchor).isActive = true
		helperElement_bottom.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -5).isActive = true
		helperElement_bottom.widthAnchor.constraint(equalToConstant: 80).isActive = true
		collectionView?.sendSubview(toBack: helperElement_bottom)
		helperElement_bottom.isHidden = true

		var hei:CGFloat = 0
		if UIDevice.current.orientation.isPortrait {
			hei = screenSize.width / 2
		}
		pHeightAnchor = profileImageView.heightAnchor.constraint(equalToConstant: hei)
		pHeightAnchor?.isActive = true
		pWidthAnchor = profileImageView.widthAnchor.constraint(equalToConstant: hei)
		pWidthAnchor?.isActive = true
		profileImageView.layer.cornerRadius = pHeightAnchor!.constant / 2
		
		profileImageView.addSubview(plus_label)
		NSLayoutConstraint.activate([
			plus_label.leftAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: 13),
			plus_label.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -33),
			plus_label.widthAnchor.constraint(equalToConstant: 40),
			plus_label.heightAnchor.constraint(equalToConstant: 40)
		])
	}
	
	


	
	private func waitResponse(){
		
		waitScreen = WaitScreen(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
		view.addSubview(waitScreen!)
		// let finded = blackView.subviews.filter{$0.accessibilityIdentifier == "actInd"}
		
	}
	
	
	
	/// при повороте экрана
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		
		if keyboardHeight != 0 {
			onChatBackingClick()
		}
		
		if UIDevice.current.orientation.isLandscape {
			print("Landscape")
			baseHeightAnchor?.constant = 0
			pHeightAnchor?.constant = 0
			pWidthAnchor?.constant = 0
		}
		else {
			print("Portrait")
			baseHeightAnchor?.constant = defaultConstHeight
			pHeightAnchor?.constant = min(screenSize.width, screenSize.height) / 2  // UIScreen.main.bounds.width / 2 - иногда крашит
			pWidthAnchor?.constant = (pHeightAnchor?.constant)!
			if loginSegmentedControl.selectedSegmentIndex == 1{
				profileImageView.layer.cornerRadius = pHeightAnchor!.constant / 2
				profileImageView.layer.masksToBounds = true
			}
			else {
				profileImageView.layer.cornerRadius = 0
			}
		}
	}
	
	

	

	/// нажали на Register/Login
	@objc private func onGoClick(){
		
		waitResponse()
		
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			onLogin()
		}
		else if loginSegmentedControl.selectedSegmentIndex == 1 {
			onRegister()
		}
	}
	
	
	
	private func onLogin(){
		
		guard let email = emailTF.text, let pass = passTF.text else {
			waitScreen?.setInfo(str: "Form is not valid")
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: pass) {
			(authResult, error) in
			if error != nil {
				print(error!.localizedDescription)
				self.waitScreen?.setInfo(str: error!.localizedDescription)
				return
			}
			
			// если всё ок - заходим в учётку
			self.waitScreen?.removeFromSuperview()
			self.messagesController?.fetchUserAndSetupNavbarTitle() // фикс бага когда выходишь и заходишь а тайтл не меняется
			self.dismiss(animated: true, completion: nil)
		}
	}
	

	
	@objc private func onSegmentedClick(){
		
		let str = loginSegmentedControl.titleForSegment(at: loginSegmentedControl.selectedSegmentIndex)
		loginRegisterBttn.setTitle(str, for: .normal)
		
		// меняем иконку аватарки/приложения
		switch_AvaLogo()
		
		// логин
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			nameTFHeightAnchor?.isActive = false
		}
		// регистрация
		else if loginSegmentedControl.selectedSegmentIndex == 1{
			nameTFHeightAnchor?.isActive = true
		}
	}
	
	
	
	

	
	private func switch_AvaLogo(){
		// логин
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			profileImageView.image = UIImage(named: "chatApp_logo")
			if UIDevice.current.orientation.isPortrait {
				profileImageView.layer.cornerRadius = 0
				profileImageView.layer.masksToBounds = false
			}
			plus_label.isHidden = true
		}
		else{
			if let selectedImage = selectedImage {
				profileImageView.image = selectedImage
				plus_label.isHidden = true
			}
			else {
				profileImageView.image = UIImage(named: default_profile_image)
				plus_label.isHidden = false
			}
			
			if UIDevice.current.orientation.isPortrait {
				profileImageView.layer.cornerRadius = pHeightAnchor!.constant / 2
				profileImageView.layer.masksToBounds = true
			}
		}
	}
	
	
	
	
	/// меняем цвет статусбара на светлый
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	
	
	
	/// клава выезжает
	@objc private func keyboardWillShow(notif: Notification){
		
		if keyboardHeight > 0 {
			return
		}
		
		if let keyboardSize = ((notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
			let offset = keyboardSize.height - helperElement_bottom.bounds.height
			
			keyboardHeight = keyboardSize.height
			
			let keyboardDuration = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
			
			if UIDevice.current.orientation.isPortrait{
				baseHeightAnchor?.constant -= offset
			}
			else { // в горизонт. режиме прокручиваем до нижнего поля
				let pointToscroll = passTF.frame.origin
				
				// if let firstResponder = collectionView?.currentFirstResponder {
				// 	 pointToscroll = CGPoint(x: firstResponder.frame.origin.x, y: firstResponder.frame.origin.y + 0)
				// }

				collectionView?.setContentOffset(pointToscroll, animated: true)
			}
			// collectionView?.contentInset.bottom = 200 // вставка контента пораждает непонятные прыжки всей вьюшки при клике по текст. полям

			UIView.animate(withDuration: keyboardDuration) {
				self.view.layoutIfNeeded()
			}
		}
	}
	
	
	
	
	/// клава заезжает
	@objc private func keyboardWillHide(notif: Notification){
		if ((notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
			
			if UIDevice.current.orientation.isPortrait{
				baseHeightAnchor?.constant = defaultConstHeight
			}
			else {
				baseHeightAnchor?.constant = 0
			}
			
			keyboardHeight = 0
			
			UIView.animate(withDuration: 0.3) {
				self.view.layoutIfNeeded()
			}
		}
	}
	
	
	
	@objc private func onChatBackingClick(){
		collectionView?.endEditing(true)
	}
	
	
	

	
//	@objc private func onSegmentedClick2(){
//		let str = loginSegmentedControl.titleForSegment(at: loginSegmentedControl.selectedSegmentIndex)
//		loginRegisterBttn.setTitle(str, for: .normal)
//
//		// изменение высоты inputsContainerView, кол-ва строк
//		nameTFHeightAnchor?.isActive = false
//		emailTFHeightAnchor?.isActive = false
//		passTFHeightAnchor?.isActive = false
//
//		// меняем иконку аватарки/приложения
//		switch_AvaLogo()
//
//		// логин
//		if loginSegmentedControl.selectedSegmentIndex == 0 {
//			inputsContainerViewHeightAnchor?.constant = 100
//
//			// т.к. nameTFHeightAnchor.multiplier - это геттер, то меняем его так(предварительно отключив):
//			nameTFHeightAnchor = nameTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
//			emailTFHeightAnchor = emailTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
//			passTFHeightAnchor = passTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
//			nameSeparator.isHidden = true
//			nameTF.isHidden = true // т.к. в iOS 10 это поле не пропадает а скукоживается
//		}
//			// регистрация
//		else if loginSegmentedControl.selectedSegmentIndex == 1{
//			inputsContainerViewHeightAnchor?.constant = 150
//			nameTFHeightAnchor = nameTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
//			emailTFHeightAnchor = emailTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
//			passTFHeightAnchor = passTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
//			nameSeparator.isHidden = false
//			nameTF.isHidden = false
//		}
//		nameTFHeightAnchor?.isActive = true
//		emailTFHeightAnchor?.isActive = true
//		passTFHeightAnchor?.isActive = true
//	}
	
	
	
//	private var point = CGPoint.zero
//
//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if let touch = touches.first {
//			let position = touch.location(in: self.view)
//			point = position
//			print(position)
//		}
//	}
//	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if let touch = touches.first {
//			let position = touch.location(in: self.view)
//			if position == point {
//				view.endEditing(true)
//				point = .zero
//			}
//		}
//	}
//
//	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//		view.endEditing(true)
//		return true
//	}
	
	

}



















