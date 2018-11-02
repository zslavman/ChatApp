//
//  Extensions.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 01.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

var imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
	
	
	public func loadImageUsingCache(urlString: String){
		
		if urlString == "none"{ // если юзер не ставил фото на профиль
			self.image = UIImage(named: default_profile_image)
			return
		}
		
		self.image = nil // для удаления предыдущей картинки в ячейке
		
		// проверяем нет ли запрашиваемой картинки в кэше
		if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
			self.image = cachedImage
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
					imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
					self.image = downloadedImage
				}
			}
		}
		downloadTask.resume()
	}
	

	
	
	
	
	
	
	
}
















