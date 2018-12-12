//
//  SettingsController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 10.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class _SettingsController: UITableViewController {


	private var Arr2D = [[String]]()
	private var LANG = 0
	
	private var localRows:[Int:[String]] = [:]
	private var localSection:[Int:[String]] = [:]
	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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

		view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		title = "Настройки"
		
		navigationController?.view.backgroundColor = UIConfig.mainThemeColor
		tableView = UITableView(frame: CGRect.zero, style: .grouped)
		
		tableView.register(UINib(nibName: "CustomCell1", bundle: nil), forCellReuseIdentifier: "ID1")
		tableView.register(UINib(nibName: "CustomCell2", bundle: nil), forCellReuseIdentifier: "ID2")
		tableView.register(UINib(nibName: "CustomCell3", bundle: nil), forCellReuseIdentifier: "ID3")
    }




	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return localSection[section]![0]
	}
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return localSection[section]![1]
	}
	
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return localRows.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return localRows[section]!.count
	}
	
	
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
//		switch(indexPath.section) {
//		case 0:
//			switch(indexPath.row) {
//			case 0: return firstNameCell   // section 0, row 0 is the first name
//			case 1: return lastNameCell    // section 0, row 1 is the last name
//			default: fatalError("Unknown row in section 0")
//			}
//		case 1:
//			switch(indexPath.row) {
//			case 0: return shareCell       // section 1, row 0 is the share option
//			default: fatalError("Unknown row in section 1")
//			}
//		default: fatalError("Unknown section")
//		}
		
		
//		if section == 0{
//
//		}
//		else if section == 1{
//			
//		}
//		else if section == 2{
//			
//		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "ID1")! as! CustomCell1
		cell.title.text = localRows[indexPath.section]![indexPath.row]
		
		
		
		return cell
	}
	
	
	

	
	
//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
//	}
	

	
	
	
	
}






















