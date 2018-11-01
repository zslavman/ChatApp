//
//  LoginController + hendlers.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 31.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


extension LoginController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	
	@objc public func onProfileClick(){
		let picker = UIImagePickerController()
		
		picker.delegate = self
		picker.allowsEditing = true
		
		present(picker, animated: true, completion: nil)
	}
	
	
	/// сюда зайдет после выбора картинки
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		var selectedImage:UIImage?
		
		if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
			selectedImage = editedImage
		}
		else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
			selectedImage = originalImage
		}
		
		if selectedImage != nil {
			profileImageView.image = selectedImage
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	
	
	
	
	public func onRegister(){
		
		guard let email = emailTF.text, let pass = passTF.text, let name = nameTF.text else {
			print("Form is not valid")
			return
		}
		Auth.auth().createUser(withEmail: email, password: pass) {
			(authResult, error) in
			
			guard let user = authResult?.user, error == nil else {
				let strErr = error!.localizedDescription
				print(strErr)
				return
			}
			
			//********************
			// Successfully auth *
			//********************
			
			// сохраняем картинку в хранилище
			let uniqueImageName = UUID().uuidString // создает уникальное имя картинке
			let storageRef = Storage.storage().reference().child("profile_images").child("\(uniqueImageName).png")
			
			if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
				storageRef.putData(uploadData, metadata: nil, completion: {
					(metadata, error) in
					if let error = error {
						print(error.localizedDescription)
						return
					}
					// когда получаем метадату, даем запрос на получение ссылки на эту картинку (разработчкики Firebase 5 - дауны)
					storageRef.downloadURL(completion: {
						(url, errorFromGettinfPicLink) in
						
						if let errorFromGettinfPicLink = errorFromGettinfPicLink {
							print(errorFromGettinfPicLink.localizedDescription)
							return
						}
						let values = [
							"name"			: name,
							"email"			: email,
							"profileImageUrl": url!.absoluteString
						]
						self.registerUserIntoDB(uid: user.uid, values: values as [String : AnyObject])
					})
					print("удачно сохранили картинку")
				})
			}
			
		}
	}
	
	
	
	// сохраняем пользователя в базу данных (строковые данные)
	private func registerUserIntoDB(uid:String, values:[String:AnyObject]){
		let ref = Database.database().reference(fromURL: "https://chatapp-2222e.firebaseio.com/")
		let usersRef = ref.child("users").child(uid)
		
		usersRef.updateChildValues(values, withCompletionBlock: {
			(err, ref) in
			if err != nil {
				print(err?.localizedDescription as Any)
				return
			}
			self.dismiss(animated: true, completion: nil)
			print("Удачно сохранили юзера")
		})
	}
	
	
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		print("canceled")
		dismiss(animated: true, completion: nil)
	}
	
	
}













