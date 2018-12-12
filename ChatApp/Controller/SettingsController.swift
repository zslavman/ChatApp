//
//  SettingsController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 12.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit



class SettingsController: UITableViewController {
	
	
	@IBOutlet weak var sw_sound: UISwitch!
	@IBOutlet weak var sw_vibro: UISwitch!
	
	@IBOutlet weak var stepper: UIStepper!
	@IBOutlet weak var mess_limit_label: UILabel!
	
	private var LANG = 1
	
	private var localRows:[Int:[String]] = [:]
	private var localSection:[Int:[String]] = [:]
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title =  dict[11]![LANG] // Настройки
		
		localRows = [
			0: [dict[0]![LANG], dict[1]![LANG]],
			1: [dict[2]![LANG]],
			2: [dict[3]![LANG], dict[4]![LANG]],
		]
		localSection = [
			0: [dict[5]![LANG], dict[6]![LANG]], // [ хэдер, футер ]
			1: [dict[7]![LANG], dict[8]![LANG]],
			2: [dict[9]![LANG], ""]
		]
		
		configureUI()
	}
	
	

	
	private func configureUI(){
		
		sw_sound.isOn = true
		sw_vibro.isOn = true
		
		mess_limit_label.text = String(Int(25))
		stepper.value = 25
	}
	
	
	/// Свитчеры
	@IBAction func onSwitcherChange(_ sender: UISwitch) {
		
		switch sender.tag {
		case 1:
			let p1 = sender.isOn
		case 2:
			let p2 = sender.isOn
//			UserDefaults.standard.set(true, forKey: "sound_mess")
//			UserDefaults.standard.synchronize()
		default: ()
		}
	}
	
	

	
	// степпер
	@IBAction func onStepperChange(_ sender: UIStepper) {
		
		let pp = Double(sender.value)
		mess_limit_label.text = String(Int(pp))
	}
	
	
	
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return localSection[section]![0]
	}
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return localSection[section]![1]
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		
		if indexPath.section == localSection.count - 1{
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

	


	
	
	
}






























