//
//  LoginController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

	public lazy var profileImageView: UIImageView = { // если не объявить как lazy то не будет работать UITapGestureRecognizer
		let imageView = UIImageView()
		imageView.image = UIImage(named: "chatApp_logo")
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onProfileClick)))
		imageView.isUserInteractionEnabled = true
		return imageView
	}()
	
	private let inputsContainerView: UIView = {
		let view_i = UIView()
		view_i.backgroundColor = .white
		// убираем дефолтные констрейнзы
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
		
		button.addTarget(self, action: #selector(onGoClick), for: UIControlEvents.touchUpInside)
		
		return button
	}()
	
	
	internal let nameTF:UITextField = {
		let tf = UITextField()
		tf.placeholder = "Name"
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	private let nameSeparator:UIView = {
		let separator = UIView()
		separator.backgroundColor = #colorLiteral(red: 0.8738058928, green: 0.8818185396, blue: 0.8798114271, alpha: 1)
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()
	//*********************
	
	internal let emailTF:UITextField = {
		let tf = UITextField()
		tf.placeholder = "Email"
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	private let emailSeparator:UIView = {
		let separator = UIView()
		separator.backgroundColor = #colorLiteral(red: 0.8738058928, green: 0.8818185396, blue: 0.8798114271, alpha: 1)
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()
	//*********************
	
	internal let passTF:UITextField = {
		let tf = UITextField()
		tf.placeholder = "Password"
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.isSecureTextEntry = true
		return tf
	}()
	
	private let passSeparator:UIView = {
		let separator = UIView()
		separator.backgroundColor = #colorLiteral(red: 0.8738058928, green: 0.8818185396, blue: 0.8798114271, alpha: 1)
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()
	//*********************
	
	
	let loginSegmentedControl:UISegmentedControl = {
		let sc = UISegmentedControl(items: ["Login", "Register"])
		sc.translatesAutoresizingMaskIntoConstraints = false
		sc.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		sc.selectedSegmentIndex = 1
		sc.addTarget(self, action: #selector(onSegmentedClick), for: UIControlEvents.valueChanged)
		return sc
	}()
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor(r: 45, g: 127, b: 193)
		view.addSubview(inputsContainerView)
		view.addSubview(loginRegisterBttn)
		view.addSubview(profileImageView)
		view.addSubview(loginSegmentedControl)
		
		setupInputsContainerView()
		setupLoginRegisterButton()
		setupProfileImageView()
		setupSegmentedControl()
	}


	
	
	private func setupSegmentedControl(){
		loginSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive 						= true
		loginSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -15).isActive = true
		loginSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1/2).isActive = true
		loginSegmentedControl.heightAnchor.constraint(equalToConstant: 50)
	}
	
	
	
	private func setupProfileImageView(){
		var size = CGSize(width: 150, height: 130)
		if UIDevice.current.orientation.isLandscape {
			size = CGSize(width: 75, height: 65)
		}
		profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive 						= true
		profileImageView.bottomAnchor.constraint(equalTo: loginSegmentedControl.topAnchor, constant: -10).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: size.width).isActive 							= true
		profileImageView.heightAnchor.constraint(equalToConstant: size.height).isActive 						= true
	}
	
	
	
	
	private var inputsContainerViewHeightAnchor:NSLayoutConstraint?
	private var nameTFHeightAnchor:NSLayoutConstraint?
	private var emailTFHeightAnchor:NSLayoutConstraint?
	private var passTFHeightAnchor:NSLayoutConstraint?
	
	private func setupInputsContainerView(){
		// добавим констрейнзы x, y, width, height
		inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive 					= true
		inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive 	= true
		inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive 		= true
		
		inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
		inputsContainerViewHeightAnchor?.isActive = true
		
		inputsContainerView.addSubview(nameTF)
		inputsContainerView.addSubview(nameSeparator)
		inputsContainerView.addSubview(emailTF)
		inputsContainerView.addSubview(emailSeparator)
		inputsContainerView.addSubview(passTF)
		inputsContainerView.addSubview(passSeparator)
		
		// текстовое поле "Имя"
		nameTF.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive 		= true
		nameTF.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive 						= true
		nameTF.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 					= true
		nameTFHeightAnchor = nameTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
		nameTFHeightAnchor?.isActive = true
		
		// линия-разделитель
		nameSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive 				= true
		nameSeparator.topAnchor.constraint(equalTo: nameTF.bottomAnchor).isActive 							= true
		nameSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 			= true
		nameSeparator.heightAnchor.constraint(equalToConstant: 1).isActive 									= true
		// текстовое поле "Email"
		emailTF.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive 		= true
		emailTF.topAnchor.constraint(equalTo: nameSeparator.bottomAnchor).isActive 							= true
		emailTF.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 					= true
		emailTFHeightAnchor = emailTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
		emailTFHeightAnchor?.isActive = true
		
		// линия-разделитель
		emailSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive 				= true
		emailSeparator.topAnchor.constraint(equalTo: emailTF.bottomAnchor).isActive 						= true
		emailSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 			= true
		emailSeparator.heightAnchor.constraint(equalToConstant: 1).isActive 								= true
		// текстовое поле "Pass"
		passTF.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive 		= true
		passTF.topAnchor.constraint(equalTo: emailSeparator.bottomAnchor).isActive 							= true
		passTF.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 					= true
		passTFHeightAnchor = passTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
		passTFHeightAnchor?.isActive = true
	}
	
	
	

	private func setupLoginRegisterButton(){
		// добавим констрейнзы x, y, width, height
		[loginRegisterBttn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		 loginRegisterBttn.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12),
		 loginRegisterBttn.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
		 loginRegisterBttn.heightAnchor.constraint(equalToConstant: 50)].forEach { (constrain) in
			constrain.isActive = true
		}
	}
	
	
	
	
	
	
	@objc private func onGoClick(){
		
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			onLogin()
		}
		else if loginSegmentedControl.selectedSegmentIndex == 1 {
			onRegister()
		}
	}
	
	
	
	private func onLogin(){
		
		guard let email = emailTF.text, let pass = passTF.text else {
			print("Form is not valid")
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: pass) {
			(authResult, error) in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			// если всё ок - заходим в учётку
			self.dismiss(animated: true, completion: nil)
		}
	}
	

	
	
	@objc private func onSegmentedClick(){
		let str = loginSegmentedControl.titleForSegment(at: loginSegmentedControl.selectedSegmentIndex)
		loginRegisterBttn.setTitle(str, for: .normal)
		
		// изменение высоты inputsContainerView, кол-ва строк
		nameTFHeightAnchor?.isActive = false
		emailTFHeightAnchor?.isActive = false
		passTFHeightAnchor?.isActive = false
		
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			inputsContainerViewHeightAnchor?.constant = 100
			
			// т.к. nameTFHeightAnchor.multiplier - это геттер, то меняем его так(предварительно отключив):
			nameTFHeightAnchor = nameTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
			emailTFHeightAnchor = emailTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
			passTFHeightAnchor = passTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
			nameSeparator.isHidden = true
		}
		else if loginSegmentedControl.selectedSegmentIndex == 1{
			inputsContainerViewHeightAnchor?.constant = 150
			nameTFHeightAnchor = nameTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
			emailTFHeightAnchor = emailTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
			passTFHeightAnchor = passTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
			nameSeparator.isHidden = false
		}
		nameTFHeightAnchor?.isActive = true
		emailTFHeightAnchor?.isActive = true
		passTFHeightAnchor?.isActive = true
	}
	
	
	
	
	
	
	
	/// меняем цвет статусбара на светлый
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

}




extension UIColor {
	
	convenience init(r:CGFloat, g:CGFloat, b:CGFloat){
		self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
	}
}















