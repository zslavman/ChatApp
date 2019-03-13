//
//  LoginController + procedure.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 31.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	// error_name=ERROR_USER_NOT_FOUND
	// Code=17011
	// There is no user record corresponding to this identifier. The user may have been deleted
	
	// error_name=ERROR_WRONG_PASSWORD
	// Code=17009
	// The password is invalid or the user does not have a password.
	
	// error_name=ERROR_EMAIL_ALREADY_IN_USE})"
	// Code=17007
	// The email address is already in use by another account.
	
	// error_name=ERROR_INVALID_EMAIL})"
	// Code=17008
	// The email address is badly formatted.
	
	// error_name=ERROR_WEAK_PASSWORD,
	// Code=17026
	// The password must be 6 characters long or more. })"
	
	@objc public func onProfileClick(){
		
		if loginSegmentedControl.selectedSegmentIndex == 0 {
			return
		}
		
		let picker = UIImagePickerController()
		
		picker.delegate = self
		picker.allowsEditing = true
		
		AppDelegate.waitScreen.show()
		
		present(picker, animated: true, completion: {
			// при первом клике долго подгружает библиотеку фоток, показываем отклик, что юзер тапнул по иконке
			AppDelegate.waitScreen.hideNow()
		})
	}
	
	
	/// сюда зайдет после выбора картинки
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

		
		var selectedImage:UIImage?
		
		if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage{
			selectedImage = editedImage
		}
		else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
			selectedImage = originalImage
		}
		if selectedImage != nil {
			profileImageView.image = selectedImage
			self.selectedImage = selectedImage
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	
	
	
	internal func onLogin(){
		guard let email = emailTF.text, let pass = passTF.text else { // чисто анбиндинг
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: pass) {
			(authResult, error) in
			if error != nil {
				print(error!.localizedDescription)
				AppDelegate.waitScreen?.setInfo(str: error!.localizedDescription)
				return
			}
			
			FCMService.setNewToken()
			
			// если всё ок - заходим в учётку
			AppDelegate.waitScreen.hideNow()
			self.messagesController?.fetchUserAndSetupNavbarTitle() // фикс бага когда выходишь и заходишь а тайтл не меняется
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	
	
	
	public func onRegister(){
		
		guard let email = emailTF.text, let pass = passTF.text, let name = nameTF.text else {
			return
		}
		
		Auth.auth().createUser(withEmail: email, password: pass) {
			(authResult, error) in
			
			guard let user = authResult?.user, error == nil else {
				let strErr = error!.localizedDescription
				AppDelegate.waitScreen?.setInfo(str: strErr)
				print(strErr)
				return
			}
			
			//********************
			// Successfully auth *
			//********************
			
			// дефолтный словарь для сохранения в БД
			var values:[String : Any] = [
				"name"			 : name,
				"email"			 : email,
				"id"			 : user.uid,
				"isOnline"		 : true,
				"profileImageUrl": "none",
				"fcmToken"		 : ""
				]
			// safety unwrapping image
			guard let profileImage = self.profileImageView.image else { return }
			
			// проверяем, если картинка профиля стоит дефолтная (не менялась)
			let isThatDefaultImage:Bool = profileImage.isEqual(UIImage(named: default_profile_image))
			if isThatDefaultImage {
				self.registerUserIntoDB(uid: user.uid, values: values as [String : AnyObject])
				return
			}
			
			// сохраняем картинку в хранилище
			let uniqueImageName = UUID().uuidString // создает уникальное имя картинке
			let storageRef = Storage.storage().reference().child("profile_images").child("\(uniqueImageName).jpg")
			
			if let uploadData = profileImage.jpegData(compressionQuality: 0.5){
				storageRef.putData(uploadData, metadata: nil, completion: {
					(metadata, error) in
					if let error = error {
						print(error.localizedDescription)
						AppDelegate.waitScreen?.setInfo(str: error.localizedDescription)
						return
					}
					// когда получаем метадату, даем запрос на получение ссылки на эту картинку (разработчкики Firebase 5 - дауны)
					storageRef.downloadURL(completion: {
						(url, errorFromGettinfPicLink) in
						
						if let errorFromGettinfPicLink = errorFromGettinfPicLink {
							print(errorFromGettinfPicLink.localizedDescription)
							AppDelegate.waitScreen?.setInfo(str: errorFromGettinfPicLink.localizedDescription)
							return
						}
						values["profileImageUrl"] = url!.absoluteString
						self.registerUserIntoDB(uid: user.uid, values: values as [String : AnyObject])
					})
					print("удачно сохранили картинку")
				})
			}
		}
	}
	
	
	
	// сохраняем пользователя в базу данных (строковые данные)
	private func registerUserIntoDB(uid:String, values:[String:AnyObject]){
		let ref = Database.database().reference()
		let usersRef = ref.child("users").child(uid)
		
		usersRef.updateChildValues(values, withCompletionBlock: {
			(err, ref) in
			if err != nil {
				print(err?.localizedDescription as Any)
				return
			}
			
			let user = User()
			user.setValuesForKeys(values)
			self.messagesController?.setupNavbarWithUser(user: user)
			
			FCMService.setNewToken() //// проверить!
			AppDelegate.waitScreen.hideNow()
			self.dismiss(animated: true, completion: nil)
			print("Удачно сохранили юзера")
		})
	}
	
	
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		print("canceled")
		dismiss(animated: true, completion: nil)
	}
	
	
	
	
	
	
	
	
	
	
	
}














// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
