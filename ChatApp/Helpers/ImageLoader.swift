//
//  ImageLoader.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 02.01.2019.
//  Copyright © 2019 Zinko Vyacheslav. All rights reserved.
//

import UIKit


class ImageLoader:Hashable {
	
	public static var imgCache = [String:UIImage]()
	
	
	// для cancel-действия в родительском классе использовать Set
	var hashValue: Int {
		return (imageURLString).hashValue
	}
	
	static func == (lhs: ImageLoader, rhs: ImageLoader) -> Bool {
		return lhs.imageURLString == rhs.imageURLString
	}
	// **********************************
	
	public let imageURLString: String
	private let completion:(UIImage?) -> ()
	
	private var isCancelled:Bool = false
	
	
	
	
	init(imageURLString: String, completion: @escaping (UIImage?) -> ()) {
		
		self.imageURLString = imageURLString
		self.completion = completion
		
		runBlock()
	}
	
	
	
	func runBlock() {
		
		if let cachedImg = ImageLoader.imgCache[imageURLString]{
			completion(cachedImg)
		}
		else {
			guard let imageURL = URL(string: self.imageURLString) else { return }
			print("скачиваем imageURL = \(imageURL)")
			
			URLSession.shared.dataTask(with: imageURL){
				(data, response, error) in
				
				if self.isCancelled { return }
				if let data = data,	let imageData = UIImage(data: data) {
					if self.isCancelled { return }
					self.completion(imageData)
					ImageLoader.imgCache[self.imageURLString] = imageData
					print("\(imageURL) --- DONE!")
				}
			}.resume()
		}
	}
	
	
	
	public func cancel(){
		isCancelled = true
	}
	
}
















