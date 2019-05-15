//
//  AboutController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 13.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import MessageUI
import Lottie

class AboutController: UIViewController, MFMailComposeViewControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate {

	private let backImage: UIImageView = {
		let bi = UIImageView()
		bi.image = UIImage(named: "about_back")
		bi.contentMode = .scaleToFill
		bi.translatesAutoresizingMaskIntoConstraints = false
		return bi
	}()
	private let logo: UIImageView = {
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
	let titleApp: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = #colorLiteral(red: 0.8950331762, green: 0.9014148843, blue: 0.9205600086, alpha: 1)
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		return label
	}()
	let support: UnselectableTextView = {
		let label = UnselectableTextView()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = #colorLiteral(red: 0.3697214447, green: 0.8389293235, blue: 1, alpha: 1)
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		label.dataDetectorTypes = .link
		label.isScrollEnabled = false
		label.isEditable = false
		label.delaysContentTouches = false
		label.linkTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(["yopta": UIColor.white])
		return label
	}()
	let bottomLabel: UILabel = {
		let label = UILabel()
		label.text = dict[39]![LANG] // Все права защищны...
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = #colorLiteral(red: 0.3529411765, green: 0.7960784314, blue: 0.9450980392, alpha: 1)
		label.font = UIFont.systemFont(ofSize: 14)
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		return label
	}()
	private let animContainer: AnimationView = {
		let cont = AnimationView(name: "like_animation")
		cont.contentMode = .scaleAspectFit
		cont.loopMode = .loop
		cont.translatesAutoresizingMaskIntoConstraints = false
		cont.animationSpeed = 0.75
		return cont
	}()
	private lazy var goBackBttn: UIButton = {
		let bttn = UIButton()
		bttn.setImage(UIImage(named: "bttn_back"), for: .normal)
		bttn.translatesAutoresizingMaskIntoConstraints = false
		bttn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
		return bttn
	}()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		SUtils.lockOrientation(.portrait)
		title = dict[4]![LANG] // О приложении
		//shouldAutorotate = false
		support.delegate = self
		installScene()
		drawNSAttrbutedTexts()
		navigationController?.setNavigationBarHidden(true, animated: true)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		animContainer.play()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		SUtils.lockOrientation(.all)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	
	@objc private func goBack() {
		self.navigationController?.popViewController(animated: true)
	}

	private func installScene() {
		view.addSubview(backImage)
		view.addSubview(logo)
		view.addSubview(bottomLabel)
		view.addSubview(support)
		view.addSubview(titleApp)
		view.addSubview(animContainer)
		view.addSubview(goBackBttn)
		
		let animContainerY = NSLayoutConstraint(item: animContainer,
									attribute: .centerY,
									relatedBy: .equal,
									toItem: view,
									attribute: .centerY,
									multiplier: 1.45,
									constant: 0)
		let logoY = NSLayoutConstraint(item: logo,
									attribute: .centerY,
									relatedBy: .equal,
									toItem: view,
									attribute: .centerY,
									multiplier: 0.6,
									constant: 0)
		NSLayoutConstraint.activate([
			backImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backImage.widthAnchor.constraint(equalTo: view.widthAnchor),
			backImage.heightAnchor.constraint(equalTo: view.heightAnchor),
			
			logo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
			logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: 0),
			logo.widthAnchor.constraint(equalTo: logo.heightAnchor),
			logoY,
			
			titleApp.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: -10),
			titleApp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			support.topAnchor.constraint(equalTo: titleApp.bottomAnchor, constant: 10),
			support.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			support.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
			support.heightAnchor.constraint(equalToConstant: 60),
			
			bottomLabel.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -20),
			bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			animContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			animContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/10),
			animContainer.widthAnchor.constraint(equalTo: animContainer.heightAnchor, multiplier: 2/1),
			animContainerY,
			
			goBackBttn.widthAnchor.constraint(equalToConstant: 75),
			goBackBttn.heightAnchor.constraint(equalToConstant: 75),
			goBackBttn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
			goBackBttn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
		])

	}
	
	
	private func drawNSAttrbutedTexts() {
		var currentVersion = dict[42]![0]
		if let bundle = Bundle.main.infoDictionary, let version = bundle["CFBundleShortVersionString"] as? String{
			currentVersion = " v" + version
		}
		// ChatApp + v1.0
		let attribetedTitle = NSMutableAttributedString(string: dict[41]![0], attributes: [NSAttributedString.Key.font : UIFont(name:"MarkerFelt-Wide", size: 30)!]) // ChatApp
		let attribetedVer = NSMutableAttributedString(string: currentVersion, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)]) // v1.0
		attribetedTitle.append(attribetedVer)
		
		titleApp.attributedText = attribetedTitle
		titleApp.layer.shadowOffset = CGSize(width: 1, height: 2)
		titleApp.layer.shadowOpacity = 0.5
		titleApp.layer.shadowRadius = 1
		
		// колдовство с надписью "Разработка и поддержка:"
		let style = NSMutableParagraphStyle()
		style.alignment = NSTextAlignment.center
		
		let styleForSupport: [NSAttributedString.Key : Any] = [
			.foregroundColor: #colorLiteral(red: 0.3529411765, green: 0.7960784314, blue: 0.9450980392, alpha: 1),
			.paragraphStyle : style,
			.font: UIFont.systemFont(ofSize: 16)
		]
		let atrSupport = NSMutableAttributedString(string: dict[40]![LANG], attributes: styleForSupport)
		
		// колдовство с линкованным текстом
		let styleForLink: [NSAttributedString.Key : Any] = [
			.foregroundColor: #colorLiteral(red: 0.3529411765, green: 0.7960784314, blue: 0.9450980392, alpha: 1),
			.paragraphStyle : style,
			.font: UIFont.systemFont(ofSize: 16),
			.underlineStyle: NSUnderlineStyle.single.rawValue,
			.link: dict[44]![0]
		]
		let attrEmail = NSMutableAttributedString(string: dict[46]![LANG])
		attrEmail.addAttributes(styleForLink, range: NSRange(location: 0, length: dict[46]![LANG].count))
		atrSupport.append(attrEmail)
		support.attributedText = atrSupport
	}
	

	private func sendMail() {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self
		
		mailComposerVC.setToRecipients([dict[44]![0]]) // email
		mailComposerVC.setSubject(dict[43]![LANG]) 		// "ChatApp проблема"
		// компонуем информацию тела письма
		let info = SUtils.gatherDeviceInfo()
		let str = "INFO: " + info.joined(separator: ", ") + "\n\n" + dict[47]![LANG] + "\n" // ... Hi Viacheslav, \n[describe problem here]
		mailComposerVC.setMessageBody(str, isHTML: false)
		mailComposerVC.navigationBar.tintColor = UIColor.white
		
		if MFMailComposeViewController.canSendMail() {
			present(mailComposerVC, animated: true, completion: nil)
		}
		else {
			AppDelegate.waitScreen?.setInfo(str: dict[45]![LANG]) // Не удалось отправить письмо
		}
	}
	
	// при окончании отправки
	func mailComposeController(_ controller: MFMailComposeViewController,
							   didFinishWith result: MFMailComposeResult,
							   error: Error?) {
		print("dismiss for MFMailComposeViewController")
		SUtils.lockOrientation(.portrait)
		controller.dismiss(animated: true, completion: nil)
	}
	
	
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		sendMail()
		return false
	}
	

	override func shouldAutomaticallyForwardRotationMethods() -> Bool {
		return false
	}
	

//	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//		return UIInterfaceOrientationMask.portrait
//	}
//	override var shouldAutorotate: Bool {
//		return false
//	}

}







// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
