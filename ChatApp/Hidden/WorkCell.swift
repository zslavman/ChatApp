//
//  WorkCell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 30.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class WorkCell: UITableViewCell {

	@IBOutlet weak var photoImage: UIImageView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	// MARK: - Public API
	var imageURLString: String? {
		didSet {
			if imageURLString != nil {
				updateImageViewWithImage(nil)
			}
		}
	}
	
	public func updateImageViewWithImage(_ image: UIImage?) {
		if let image = image {
			photoImage.image = image
			photoImage.alpha = 0.35
			photoImage.layer.cornerRadius = 8
			photoImage.clipsToBounds = true
			UIView.animate(withDuration: 0.2, animations: {
				self.photoImage.alpha = 1.0
				self.spinner.alpha = 0
			}, completion: {
				_ in
				self.spinner.stopAnimating()
			})
		}
		else {
			//photoImage.image = nil
			//photoImage.alpha = 0
			spinner.alpha = 1.0
			spinner.startAnimating()
		}
	}

}













