//
//  WaitScreen.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 28.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//	Класс убивается самостоятельно если вызвать setInfo() иначе вручную удалять из вьюшки

import UIKit

class WaitScreen: UIView {

	
	private var blackView: UIView!
	private var activityIndicator:UIActivityIndicatorView!
	private var textBacking:UIView!
	private var textView:UITextView!
	
	
	
	
	override init(frame: CGRect) {
		super.init(frame: UIScreen.main.bounds)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	
	public func setup(){
		
		self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		
		// фон
		blackView = UIView()
		blackView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
		blackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(blackView)
		
		NSLayoutConstraint.activate([
			blackView.topAnchor.constraint(equalTo: self.topAnchor),
			blackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			blackView.leftAnchor.constraint(equalTo: self.leftAnchor),
			blackView.rightAnchor.constraint(equalTo: self.rightAnchor)
		])
		//******************************
		
		// круговой индикатор
		activityIndicator = UIActivityIndicatorView()
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = .whiteLarge
		activityIndicator.startAnimating()
		activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.75)
		activityIndicator.layer.cornerRadius = 15
		activityIndicator.layer.masksToBounds = true
		activityIndicator.accessibilityIdentifier = "actInd"
		blackView.addSubview(activityIndicator)
		
		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: blackView.centerYAnchor),
//			activityIndicator.centerYAnchor.constraint(equalTo: blackView.topAnchor, constant: 120),
			activityIndicator.widthAnchor.constraint(equalToConstant: 80),
			activityIndicator.heightAnchor.constraint(equalToConstant: 80)
		])
		//******************************
		
		// фон текста ошибки
		textBacking = UIView()
		textBacking.translatesAutoresizingMaskIntoConstraints = false
		textBacking.backgroundColor = UIColor.black.withAlphaComponent(0.75)
		textBacking.layer.cornerRadius = 15
		textBacking.layer.masksToBounds = true
		blackView.addSubview(textBacking)
		textBacking.isHidden = true
		textBacking.layer.borderWidth = 1.4
		textBacking.layer.borderColor = UIColor.white.cgColor
		
		NSLayoutConstraint.activate([
			textBacking.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
			textBacking.centerYAnchor.constraint(equalTo: blackView.centerYAnchor, constant: -30),
			textBacking.widthAnchor.constraint(equalToConstant: 300),
			textBacking.heightAnchor.constraint(equalToConstant: 160)
		])
		
		//******************************
		
		// текст ошибки
		textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.textColor = UIColor.white
		textView.font = UIFont.systemFont(ofSize: 18)
		textView.isScrollEnabled = false
		textView.isEditable = false
		textView.isSelectable = false
		textView.textAlignment = .center
		textView.backgroundColor = UIColor.clear
		textBacking.addSubview(textView)
		
		NSLayoutConstraint.activate([
			textView.centerXAnchor.constraint(equalTo: textBacking.centerXAnchor),
			textView.centerYAnchor.constraint(equalTo: textBacking.centerYAnchor),
			textView.widthAnchor.constraint(equalTo: textBacking.widthAnchor, multiplier: 0.9)
		])
		
	}
	
	
	
	
	
	public func setInfo(str:String){
		
		activityIndicator.stopAnimating()
		textBacking.isHidden = false
		textView.text = str
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			
			UIView.animate(withDuration: 1, animations: {
				self.alpha = 0
				self.transform = CGAffineTransform(scaleX: 2, y: 2)
			}, completion: {
				(bool) in
				self.removeFromSuperview()
				AppDelegate.waitScreen = nil
			})
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

}
