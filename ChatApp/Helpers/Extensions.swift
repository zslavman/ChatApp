//
//  Extensions.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 01.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

//var imageCache = NSCache<AnyObject, AnyObject>()
var imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
	
	
	/// загрузчик картинок с внешних адресов (использует кэш)
	public func loadImageUsingCache(urlString: String, completionHandler: ((UIImage) -> ())? ){
		
		/// внутренняя подфункция проверяющая есть ли колбэк
		func setImageForUIView(_ gotImage:UIImage){
			if let completionHandler = completionHandler { // если есть колбэк - вызываем его
				completionHandler(gotImage)
			}
			else {
				DispatchQueue.main.async {
					self.image = gotImage
				}
			}
		}
		//*******************************
		
		
		
		if urlString == "none"{ // если юзер не ставил фото на профиль, грузим дефолтную пикчу
			let img = UIImage(named: default_profile_image)!
			setImageForUIView(img)
			return
		}
		
//		self.image = nil // для удаления предыдущей картинки в ячейке
		
		// проверяем нет ли запрашиваемой картинки в кэше
		if let cachedImage = imageCache.object(forKey: urlString as NSString) {
			setImageForUIView(cachedImage)
			return
		}
		
		let downloadTask = URLSession.shared.dataTask(with: URL(string: urlString)!) {
			(data, response, error) in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			DispatchQueue.main.async {
				
				if let downloadedImage = UIImage(data: data!){
					imageCache.setObject(downloadedImage, forKey: urlString as NSString)
					setImageForUIView(downloadedImage)
				}
			}
		}
		downloadTask.resume()
	}
	

	
	
}






















