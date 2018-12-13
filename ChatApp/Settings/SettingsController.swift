//
//  SettingsController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 12.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

struct UserDefFlags {
	
	private enum keys:String {
		case sound_mess = "sound_mess"
		case vibro_mess = "vibro_mess"
		case limit_mess = "limit_mess"
		case lang 		= "lang"
	}
	
	static var sound_mess:Bool! {
		didSet{
			save(value: sound_mess, key: .sound_mess)
		}
	}
	static var vibro_mess:Bool! {
		didSet{
			save(value: vibro_mess, key: .vibro_mess)
		}
	}
	static var limit_mess:UInt! {
		didSet{
			save(value: limit_mess, key: .limit_mess)
		}
	}
	static var lang:UInt! {
		didSet{
			save(value: lang, key: .lang)
			LANG = Int(lang)
		}
	}
	
	init() {
		let s_flag = UserDefaults.standard.object(forKey: keys.sound_mess.rawValue)
		UserDefFlags.sound_mess = (s_flag == nil) ? true : s_flag as! Bool

		let v_flag = UserDefaults.standard.object(forKey: keys.vibro_mess.rawValue)
		UserDefFlags.vibro_mess = (v_flag == nil) ? false : v_flag as! Bool
		
		let lim_flag = UserDefaults.standard.object(forKey: keys.limit_mess.rawValue)
		UserDefFlags.limit_mess = (lim_flag == nil) ? 25 : lim_flag as! UInt
		
		let lang_flag = UserDefaults.standard.object(forKey: keys.lang.rawValue)
		UserDefFlags.lang = (lang_flag == nil) ? 0 : lang_flag as! UInt
	}
	
	
	private static func save(value:Any, key:keys){
//		print("key = \(key.rawValue) ---> value = \(value)")
		UserDefaults.standard.set(value, forKey: key.rawValue)
		UserDefaults.standard.synchronize()
	}
}





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
			2: [dict[3]![LANG], dict[4]![LANG]],
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
	
	

	
	// степпер
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
		
		if indexPath.section == 2 || indexPath.section == 3{
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
		
		if indexPath.section == 2 && indexPath.row == 0 {
			let vc = ChangeLanguageController()
			navigationController?.pushViewController(vc, animated: true)
		}
		
		
	}
	
	
}




































