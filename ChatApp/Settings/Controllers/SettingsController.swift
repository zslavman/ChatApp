//
//  SettingsController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 12.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SettingsController: UITableViewController {
	
	
	@IBOutlet weak var sw_sound: UISwitch!
	@IBOutlet weak var sw_vibro: UISwitch!
	
	@IBOutlet weak var stepper: UIStepper!
	@IBOutlet weak var mess_limit_label: UILabel!
	
	private var localRows:[Int:[String]] = [:]
	private var localSection:[Int:[String]] = [:]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureLocales()
		configureUI()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureLocales()
	}

	
	private func configureLocales(){
		title =  dict[17]![LANG] // Настройки
		localRows = [
			0: [dict[0]![LANG], dict[1]![LANG]],
			1: [dict[2]![LANG]],
			2: [dict[48]![LANG], dict[3]![LANG], dict[4]![LANG]],
			3: [dict[12]![LANG]]
		]
		localSection = [
			0: [dict[5]![LANG], dict[6]![LANG]], // [ хэдер, футер ]
			1: [dict[7]![LANG], dict[8]![LANG]],
			2: [dict[9]![LANG], ""],
			3: ["", dict[13]![LANG]]
		]
		tableView.reloadData()
	}
	
	
	private func configureUI(){
		sw_sound.isOn = UserDefFlags.sound_mess
		sw_vibro.isOn = UserDefFlags.vibro_mess
		
		mess_limit_label.text = String(Int(UserDefFlags.limit_mess))
		stepper.value = Double(UserDefFlags.limit_mess)
	}
	
	
	/// Свитчеры
	@IBAction func onSwitcherChange(_ sender: UISwitch) {
		switch sender.tag {
		case 1:
			UserDefFlags.sound_mess = sender.isOn
		case 2:
			UserDefFlags.vibro_mess = sender.isOn
		default: ()
		}
	}
	

	/// степпер
	@IBAction func onStepperChange(_ sender: UIStepper) {
		UserDefFlags.limit_mess = UInt(sender.value)
		mess_limit_label.text = String(Int(UserDefFlags.limit_mess))
	}
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return localSection[section]![0]
	}
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return localSection[section]![1]
	}
	//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	//		tableView.deselectRow(at: indexPath, animated: true)
	//	}

	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		
		if indexPath.section == 2 || indexPath.section == 3 {
			// цвет выделения при клике на ячейку
			let selectionColor = UIView()
			selectionColor.backgroundColor = ChatMessageCell.blueColor.withAlphaComponent(0.45)
			cell.selectedBackgroundView = selectionColor
			cell.selectionStyle = .default
		}
		// название внутри ячейки
		for view in cell.contentView.subviews {
			if let label = view as? UILabel {
				if label.tag == 0 {
					label.text = localRows[indexPath.section]![indexPath.row]
				}
			}
		}
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 2 {
			// Edit profile
			if indexPath.row == 0 {
				let alertController = SUtils.alert(message: dict[49]![LANG], completion: {
					tableView.deselectRow(at: indexPath, animated: true)
				})
				present(alertController, animated: true, completion: nil)
			}
			// Language
			if indexPath.row == 1 {
				let vc = ChangeLanguageController()
				vc.hidesBottomBarWhenPushed = true
				navigationController?.pushViewController(vc, animated: true)
			}
			// About
			if indexPath.row == 2 {
				let vc = AboutController()
				vc.hidesBottomBarWhenPushed = true
				navigationController?.pushViewController(vc, animated: true)
			}
		}
		// Logout
		if indexPath.section == 3 && indexPath.row == 0 {
			logout()
			tabBarController?.selectedIndex = 0
		}
	}
	
	
	private func logout() {
		APIServices.facebookLogout()
		GIDSignIn.sharedInstance()?.signOut()
		GIDSignIn.sharedInstance()?.disconnect()
		let messagesController = tabBarController?.viewControllers![0].children.first as! MessagesController
		messagesController.dispose()
		
		let findUsersController = tabBarController?.viewControllers![1].children.first as! FindUserForChatController
		findUsersController.dispose()
		
		let loginController = LoginController(collectionViewLayout: UICollectionViewFlowLayout())
		// фикс бага когда выходишь и регишся а тайтл не меняется
		loginController.messagesController = messagesController
		
		present(loginController, animated: true, completion: nil)
	}
	
	
	
}




































