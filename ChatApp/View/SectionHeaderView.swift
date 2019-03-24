//
//  SectionHeaderView.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 17.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
	
	public static let grey = #colorLiteral(red: 0.9217745254, green: 0.9309010058, blue: 0.9309010058, alpha: 1)
	
	public var title:UILabelWithEdges = {
		let label = UILabelWithEdges()
		label.font = UIFont.systemFont(ofSize: 14)
		label.textColor = #colorLiteral(red: 0.7918348512, green: 0.7996748003, blue: 0.7996748003, alpha: 1)
		label.textAlignment = .center
		label.backgroundColor = .white
		label.layer.borderWidth = 1
		label.layer.borderColor = grey.cgColor
		label.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
		label.layer.cornerRadius = 13
		label.layer.masksToBounds = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let line:UIView = {
		let line = UIView()
		line.backgroundColor = grey
		line.translatesAutoresizingMaskIntoConstraints = false
		return line
	}()
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(line)
		addSubview(title)
		
		title.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		title.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		
		line.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		line.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
		line.heightAnchor.constraint(equalToConstant: 1).isActive = true
	}
}






















