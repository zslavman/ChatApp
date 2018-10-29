//
//  LoginController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

	private let profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "chatApp_logo")
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let inputsContainerView: UIView = {
		let view_i = UIView()
		view_i.backgroundColor = .white
		// убираем дефолтные констрейнзы
		view_i.translatesAutoresizingMaskIntoConstraints = false
		view_i.layer.cornerRadius = 8
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
		return button
	}()
	
	
	private let nameTF:UITextField = {
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
	
	private let emailTF:UITextField = {
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
	
	private let passTF:UITextField = {
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
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor(r: 45, g: 127, b: 193)
		view.addSubview(inputsContainerView)
		view.addSubview(loginRegisterBttn)
		view.addSubview(profileImageView)
		
		setupInputsContainerView()
		setupLoginRegisterButton()
		setupProfileImageView()
	}


	
	private func setupProfileImageView(){
		profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive 						= true
		profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -20).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive 									= true
		profileImageView.heightAnchor.constraint(equalToConstant: 130).isActive 								= true
	}
	
	
	
	
	private func setupInputsContainerView(){
		// добавим констрейнзы x, y, width, height
		[inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		 inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		 inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
		 inputsContainerView.heightAnchor.constraint(equalToConstant: 150)].forEach { (constrain) in
			constrain.isActive = true
		}
		
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
		nameTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
		// линия-разделитель
		nameSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive 				= true
		nameSeparator.topAnchor.constraint(equalTo: nameTF.bottomAnchor).isActive 							= true
		nameSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 			= true
		nameSeparator.heightAnchor.constraint(equalToConstant: 1).isActive 									= true
		// текстовое поле "Email"
		emailTF.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive 		= true
		emailTF.topAnchor.constraint(equalTo: nameSeparator.bottomAnchor).isActive 							= true
		emailTF.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 					= true
		emailTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
		// линия-разделитель
		emailSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive 				= true
		emailSeparator.topAnchor.constraint(equalTo: emailTF.bottomAnchor).isActive 						= true
		emailSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 			= true
		emailSeparator.heightAnchor.constraint(equalToConstant: 1).isActive 								= true
		// текстовое поле "Pass"
		passTF.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive 		= true
		passTF.topAnchor.constraint(equalTo: emailSeparator.bottomAnchor).isActive 							= true
		passTF.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive 					= true
		passTF.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
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















