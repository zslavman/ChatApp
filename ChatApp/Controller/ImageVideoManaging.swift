//
//  ImageManaging.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 04.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Firebase

extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	
	/// клик на картинку (переслать фотку)
	@objc public func onUploadClick(){
		
		AppDelegate.waitScreen.show()
		
		let imagePickerController = UIImagePickerController()
		
		imagePickerController.allowsEditing = true
		imagePickerController.delegate = self
		// разрешаем выбирать видеофайлы из библиотеки
		imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
		
		selectMediaContentOpened = true
		present(imagePickerController, animated: true, completion: {
			AppDelegate.waitScreen.hideNow()
		})
	}
	
	
	
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		var permission:Bool = true
		selectMediaContentOpened = false
		
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
	
	
	
	
	/// сохранение сообщения с картинкой в БД
	private func sendMessageWithImage(imageUrl: String, image: UIImage){
		let properties:[String:Any] = [
			"imageUrl"		:imageUrl,
			"imageWidth"	:image.size.width,
			"imageHeight"	:image.size.height
		]
		sendMessage_with_Properties(properties: properties)
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
	
	
	
	
	
	
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		selectMediaContentOpened = true
		dismiss(animated: true, completion: nil)
	}
	
	
	

	
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
	
	
	
	
	
}














