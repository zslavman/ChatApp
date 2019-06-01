//
//  LoginController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FBSDKCoreKit


let default_profile_image: String = "default_profile_image"


class LoginController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
	
	internal var messagesController: MessagesController?

	private let BUTTON_HEIGHT: CGFloat = 40
	private let BUTTON_WIDTH: CGFloat = 180
	public lazy var profileImageView: UIImageView = { // если не объявить как lazy то не будет работать UITapGestureRecognizer
		let imageView = UIImageView()
		imageView.image = UIImage(named: default_profile_image)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onProfileClick)))
		imageView.isUserInteractionEnabled = true
		imageView.layer.masksToBounds = true
		imageView.alpha = 1
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
	private let loginRegisterBttn: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		button.layer.cornerRadius = 8
		button.setTitle("Register", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.shadowOffset = CGSize(width: 0, height: 3)
		button.layer.shadowRadius = 3
		button.layer.shadowOpacity = 0.15
		button.addTarget(self, action: #selector(onGoClick), for: .touchUpInside)
		return button
	}()
	private lazy var loginViaFB_Bttn: UIButton = {
		let button = UIButton(type: .system)
		button.customizeSignInButton(btnWidth: BUTTON_WIDTH,
										backColor: #colorLiteral(red: 0.1960784314, green: 0.3058823529, blue: 0.5450980392, alpha: 1),
										title: dict[58]![LANG],
										titleColor: .white,
										imageIcon: #imageLiteral(resourceName: "facebook_logo_small"))
		button.tintColor = .white
		button.addTarget(self, action: #selector(onLoginViaFB_Click), for: .touchUpInside)
		return button
	}()
	internal let nameTF: UITextField = {
		let tf = UITextField()
		tf.placeholder = dict[27]![LANG] // Имя
		tf.backgroundColor = .white
		tf.autocapitalizationType = .words
		tf.autocorrectionType = UITextAutocorrectionType.no
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf.frame.height))
		tf.leftViewMode = .always
		tf.layer.cornerRadius = 7
		tf.layer.masksToBounds = true
		return tf
	}()
	private let nameSeparator: UIView = {

		let separator = UIView()
		separator.backgroundColor = UIColor.lightGray
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()
	//*********************
	internal let emailTF: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Email"
		tf.backgroundColor = .white
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.keyboardType = .emailAddress
		tf.autocorrectionType = UITextAutocorrectionType.no
		tf.autocapitalizationType = .none
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf.frame.height))
		tf.leftViewMode = .always
		//tf.text = "A24@gmail.com" // потом убрать!
		tf.layer.cornerRadius = 7
		tf.layer.masksToBounds = true
		return tf
	}()
	internal let passTF: UITextField = {
		let tf = UITextField()
		tf.placeholder = dict[26]![LANG] // Пароль
		tf.backgroundColor = .white
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.isSecureTextEntry = true
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf.frame.height))
		tf.leftViewMode = .always
		//tf.text = "111111" // потом убрать!
		tf.layer.cornerRadius = 7
		tf.layer.masksToBounds = true
		return tf
	}()
	internal let loginSegmentedControl: UISegmentedControl = {
		let sc = UISegmentedControl(items: [dict[11]![LANG], dict[25]![LANG]]) // Login, Register
		sc.translatesAutoresizingMaskIntoConstraints = false
		sc.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		sc.selectedSegmentIndex = 1
		sc.addTarget(self, action: #selector(onSegmentedClick), for: UIControl.Event.valueChanged)
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
		// повернем изображение на 180 (при этом повернутся и все его эффекты)
		plus.transform = CGAffineTransform(rotationAngle: 180 / 180 * CGFloat.pi)
		plus.layer.shadowOffset = CGSize(width: 0, height: -3)
		plus.layer.shadowRadius = 3
		plus.layer.shadowOpacity = 0.3
		return plus
	}()
	internal var selectedImage: UIImage? {
		didSet{
			plus_label.isHidden = true
		}
	}
	private var mainStackView: UIStackView!
	private var nameTFHeightAnchor: NSLayoutConstraint?
	
	private var keyboardHeight: CGFloat = 0
	private let defaultConstHeight: CGFloat = -35
	private var baseHeightAnchor: NSLayoutConstraint? // смещение центра основного контейнера по Y
	private var pHeightAnchor: NSLayoutConstraint? // высота фотки
	private var pWidthAnchor: NSLayoutConstraint? // ширина фотки
	private var screenSize = CGSize.zero
	private var startingLoginToFB: Bool = false { // flag for switch StatusBarAppearance
		didSet {
			let style: UIStatusBarStyle = (startingLoginToFB) ? .default : .lightContent
			setStatusBarStyle(style)
		}
	}
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	
	override func viewDidLoad() {
        super.viewDidLoad()
		collectionView?.alwaysBounceVertical = true
		collectionView?.keyboardDismissMode = .interactive
		// collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "reuseIdentifier")
		collectionView?.backgroundColor = UIConfig.mainThemeColor
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
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	
	/// меняем цвет статусбара на светлый
//	override var preferredStatusBarStyle: UIStatusBarStyle {
//		return (startingLoginToFB) ? .default : .lightContent
//	}
	

	private func setup_UI() {
		// стейвью для полей ввода
		let inputsStackView = UIStackView(arrangedSubviews: [nameTF, emailTF, passTF])
		inputsStackView.axis 		 = .vertical
		inputsStackView.alignment 	 = .center
		inputsStackView.distribution = .fill
		inputsStackView.spacing 	 = 5
		inputsStackView.translatesAutoresizingMaskIntoConstraints = false
		
		let uiArr = [
			profileImageView,
			loginSegmentedControl,
			inputsStackView,
			loginRegisterBttn,
			loginViaFB_Bttn
		]
		
		// главный стеквью
		mainStackView = UIStackView(arrangedSubviews: uiArr)
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
		
		loginSegmentedControl.widthAnchor.constraint(equalToConstant: BUTTON_WIDTH).isActive = true
		loginSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		loginRegisterBttn.widthAnchor.constraint(equalToConstant: BUTTON_WIDTH).isActive = true
		loginRegisterBttn.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT).isActive = true
		
		loginViaFB_Bttn.widthAnchor.constraint(equalToConstant: BUTTON_WIDTH).isActive = true
		loginViaFB_Bttn.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT).isActive = true
		loginViaFB_Bttn.topAnchor.constraint(equalTo: loginRegisterBttn.bottomAnchor, constant: 8).isActive = true
		
		inputsStackView.leftAnchor.constraint(equalTo: mainStackView.leftAnchor).isActive 	= true
		inputsStackView.rightAnchor.constraint(equalTo: mainStackView.rightAnchor).isActive = true
		
		let const = (UIScreen.main.bounds.width < UIScreen.main.bounds.height) ? defaultConstHeight : 0
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
		collectionView?.sendSubviewToBack(helperElement_bottom)
		helperElement_bottom.isHidden = true

		var hei:CGFloat = 0
		if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
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
	
	

	/// при повороте экрана
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		if keyboardHeight != 0 {
			onChatBackingClick()
		}
		if size.width > size.height {
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
	
	
	/// Register/Login clicked
	@objc private func onGoClick() {
		onChatBackingClick()
		AppDelegate.waitScreen.show()
		
		let ema = emailTF.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		let pas = passTF.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		let nam = nameTF.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		let forLogin: [String] = [ema, pas]
		let forRegis: [String] = [ema, pas, nam]
		
		// on login
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			let temp1 = forLogin.compactMap{!$0.isEmpty ? $0 : nil}
			guard temp1.count == forLogin.count else {
				AppDelegate.waitScreen?.setInfo(str: dict[28]![LANG]) // Empty field(s) detected
				return
			}
		}
		// on register
		else {
			let temp2 = forRegis.compactMap{!$0.isEmpty ? $0 : nil}
			if temp2.count != forRegis.count {
				AppDelegate.waitScreen?.setInfo(str: dict[28]![LANG])
				return
			}
		}
		guard SUtils.isValidEmail(maybeEmail: ema) else {
			AppDelegate.waitScreen?.setInfo(str: dict[57]![LANG]) // Not valid email
			return
		}
		loginSegmentedControl.selectedSegmentIndex == 0 ? onLogin() : onRegister()
	}
	
	
	
	@objc private func onLoginViaFB_Click() {
		onChatBackingClick()
		startingLoginToFB = true
		let loginManager = LoginManager()
		loginManager.loginBehavior = .web
		loginManager.logIn(readPermissions: [.publicProfile], viewController: self) {
			(loginResult) in
			self.startingLoginToFB = false
			switch loginResult {
			case .failed(let error):
				print(error.localizedDescription)
			case .cancelled:
				print("User cancelled login")
			case .success(_, _, let accessToken):
				let authToken = accessToken.authenticationToken
				let credential = FacebookAuthProvider.credential(withAccessToken: authToken)
				// Perform login by calling Firebase APIs
				AppDelegate.waitScreen.show()
				Auth.auth().signInAndRetrieveData(with: credential, completion: {
					(receivedData, error) in
					
					if let error = error {
						print(error.localizedDescription)
						return
					}
					print("Logining...")
					guard let fireUser = receivedData?.user else { return }
					DispatchQueue.main.async {
						self.analizeReceivedUser(user: fireUser)
					}
				})
			}
		}
	}
	
	
	private func analizeReceivedUser(user: User) {
		let maybeEmail = user.email ?? user.providerData.first?.providerID ?? "Facebook"
		
		let userValues:[String : Any] = [
			"name"			 : user.displayName ?? "noname",
			"email"			 : maybeEmail,
			"id"			 : user.uid,
			"isOnline"		 : true,
			"profileImageUrl": user.photoURL?.absoluteString ?? "none",
			"fcmToken"		 : "",
			"lastVisit"		 : String(Int(Date().timeIntervalSince1970))
		]
		if user.email == nil { // if FB didn't give email
			
		}
		// update user in FireBaseDB, goto main screen
		registerUserIntoDB(uid: user.uid, values: userValues as [String : AnyObject])
	}
	
	
	
	
	/// клик на segmentedControl
	@objc private func onSegmentedClick() {
		let str = loginSegmentedControl.titleForSegment(at: loginSegmentedControl.selectedSegmentIndex)
		loginRegisterBttn.setTitle(str, for: .normal)
		// меняем иконку аватарки/приложения
		switch_AvaLogo()
		// логин
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			nameTFHeightAnchor?.constant = 0
		}
		// регистрация
		else if loginSegmentedControl.selectedSegmentIndex == 1{
			nameTFHeightAnchor?.constant = 40
		}
	}
	
	
	/// переключение
	private func switch_AvaLogo() {
		// логин
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			profileImageView.image = UIImage(named: "chatApp_logo")
			if UIScreen.main.bounds.width < UIScreen.main.bounds.height{
				profileImageView.layer.cornerRadius = 0
				profileImageView.layer.masksToBounds = false
			}
			plus_label.isHidden = true
		}
		else {
			if let selectedImage = selectedImage {
				profileImageView.image = selectedImage
				plus_label.isHidden = true
			}
			else {
				profileImageView.image = UIImage(named: default_profile_image)
				plus_label.isHidden = false
			}
			
			if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
				profileImageView.layer.cornerRadius = pHeightAnchor!.constant / 2
				profileImageView.layer.masksToBounds = true
			}
		}
	}
	

	/// клава выезжает
	@objc private func keyboardWillShow(notif: Notification) {
		if keyboardHeight > 0 {
			return
		}
		if let keyboardSize = ((notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
			let offset = keyboardSize.height - helperElement_bottom.bounds.height
			
			keyboardHeight = keyboardSize.height
			 let keyboardDuration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
			
			if UIScreen.main.bounds.width < UIScreen.main.bounds.height{
				self.baseHeightAnchor?.constant -= offset
				
				UIView.animate(withDuration: keyboardDuration) {
					self.collectionView?.layoutIfNeeded()
				}
			}
			else { // в горизонт. режиме прокручиваем до нижнего поля
				let pointToscroll = passTF.frame.origin
				// нужно именно в основном потоке, т.к. на emailTF не срабатывало (скорее всего потому что отключил autocorrectionType)
				DispatchQueue.main.async {
					self.collectionView?.setContentOffset(pointToscroll, animated: true)
				}
			}
			// collectionView?.contentInset.bottom = 200 // вставка контента пораждает непонятные прыжки всей вьюшки при клике по текст. полям
		}
	}
	
	
	/// клава заезжает
	@objc private func keyboardWillHide(notif: Notification){
		if ((notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
			if UIScreen.main.bounds.width < UIScreen.main.bounds.height{
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
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		onChatBackingClick()
		return true
	}
	
	
	@objc private func onChatBackingClick(){
		collectionView?.endEditing(true)
	}
	


}



