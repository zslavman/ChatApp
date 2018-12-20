//
//  HeaderViewStretch.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 20.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit


class HeaderViewStretch: UITableView {
	
	
	private var headerViewHeight: NSLayoutConstraint?
	private var bottomOfPicture: NSLayoutConstraint?
	
	
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		guard let header = tableHeaderView else { return }
		guard let imageView = header.subviews.first as? UIImageView else { return }
		
		// headerViewHeight = imageView.constraints.filter{$0.firstAttribute == .height}.first // невозможно правильно получить из сторибоарда таким образом
		headerViewHeight = imageView.constraints.filter{$0.identifier == "picHeight"}.first
		bottomOfPicture = header.constraints.filter{$0.identifier == "picBottom"}.first
		
		
		let offsetY = -contentOffset.y
		bottomOfPicture?.constant = offsetY >= 0 ? 0 : offsetY / 2
		header.clipsToBounds = offsetY <= 0 // фикс пробела сверху
		headerViewHeight?.constant = max(header.bounds.height, header.bounds.height + offsetY)
		
		
		
	}
	
	
	
	
	
	
}
