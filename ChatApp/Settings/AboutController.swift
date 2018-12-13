//
//  AboutController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 13.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class AboutController: UIViewController {

	
	private let backImage:UIImageView = {
		let bi = UIImageView()
		bi.image = UIImage(named: "about_back")
		bi.contentMode = .scaleToFill
		bi.translatesAutoresizingMaskIntoConstraints = false
		return bi
	}()
	
	
	private let logo: UIImageView = { // если не объявить как lazy то не будет работать UITapGestureRecognizer
		let imageView = UIImageView()
		imageView.image = UIImage(named: "chatApp_logo")
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.isUserInteractionEnabled = true
		imageView.layer.masksToBounds = true
		imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
		imageView.layer.shadowRadius = 5
		imageView.layer.shadowOpacity = 0.2
		return imageView
	}()
	
	let titleApp:UILabel = {
		let label = UILabel()
		label.text = dict[41]![LANG] // ChatApp
//		label.font = UIFont(name:"MarkerFelt-Wide", size: 30)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = #colorLiteral(red: 0.9764705882, green: 0.9843137255, blue: 0.9921568627, alpha: 1)
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		return label
	}()
	
	let support:UILabel = {
		let label = UILabel()
		label.numberOfLines = 2
		label.text = dict[40]![LANG] // Разработка и поддержка
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = #colorLiteral(red: 0.3697214447, green: 0.8389293235, blue: 1, alpha: 1)
		label.font = UIFont.systemFont(ofSize: 16)
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		return label
	}()
	
	let bottomLabel:UILabel = {
		let label = UILabel()
		label.text = dict[39]![LANG] // Все права защищны...
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = #colorLiteral(red: 0.3529411765, green: 0.7960784314, blue: 0.9450980392, alpha: 1)
		label.font = UIFont.systemFont(ofSize: 14)
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		return label
	}()
	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = dict[4]![LANG] // О приложении
		//shouldAutorotate = false
		
		let attribetedTitle = NSMutableAttributedString(string: dict[41]![LANG], attributes: [NSAttributedStringKey.font : UIFont(name:"MarkerFelt-Wide", size: 30)!])
		let attribetedVer = NSMutableAttributedString(string: dict[42]![LANG], attributes: [NSAttributedStringKey.font : UIFont(name:"AppleSDGothicNeo-Medium", size: 18)!])
		attribetedTitle.append(attribetedVer)
		titleApp.attributedText = attribetedTitle
		
		installScene()
	}
	
	
	
	
	private func installScene(){
		
		
		
		
		view.addSubview(backImage)
		view.addSubview(logo)
		view.addSubview(bottomLabel)
		view.addSubview(support)
		view.addSubview(titleApp)
		
		
		NSLayoutConstraint.activate([
			backImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backImage.widthAnchor.constraint(equalTo: view.widthAnchor),
			backImage.heightAnchor.constraint(equalTo: view.heightAnchor),
			
			logo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
			logo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
			logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: 0),
			logo.widthAnchor.constraint(equalTo: logo.heightAnchor),
			
			titleApp.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 0),
			titleApp.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			support.topAnchor.constraint(equalTo: titleApp.bottomAnchor, constant: 10),
			support.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			bottomLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
			bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
		])
		
		
	}
	
	
	
	
	override func shouldAutomaticallyForwardRotationMethods() -> Bool {
		return false
	}
	
//	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//		get {
//			return .portrait
//		}
//	}


	

}




















