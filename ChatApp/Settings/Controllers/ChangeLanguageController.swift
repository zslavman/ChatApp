//
//  ChangeLanguageController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 12.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit



class ChangeLanguageController: UITableViewController {
	
	
	private let ID:String = "ID"
	private var dataArr = [String]()
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		dataArr = dict[10]!
		
		tableView = UITableView(frame: CGRect.zero, style: .grouped)
		
		title = dict[14]![LANG]
		tableView.register(LangCell.self, forCellReuseIdentifier: ID)
		
//		navigationItem.leftItemsSupplementBackButton = true
//		navigationItem.setHidesBackButton(true, animated: false)
		
		// скрываем родную навбаровскую кнопку назад. т.к. будем менять язык а до нее не добраться
//		let tp = UIBarButtonItem(image: UIImage(named: "bttn_back"), style: .plain, target: self, action: #selector(goBack))
//		navigationItem.setLeftBarButton(tp, animated: true)
	}
	


	
	
//	@objc private func goBack(){
//		self.navigationController?.popViewController(animated: true)
//	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath) as! LangCell
		cell.textLabel?.text = dataArr[indexPath.row]
		
		cell.selectionStyle = .none
		
		if indexPath.row == LANG {
			tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
		}
	
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataArr.count
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// переключаем язык приложения
		UserDefFlags.lang = UInt(indexPath.row)
		
		// этот тайтл
		title = dict[14]![LANG]
		
		// тайтл предыдушего вьюконтроллера
		// navigationController?.navigationBar.backItem?.title = dict[17]![LANG]
		
		// лайфхак - как поменять текст в backButton
		navigationController?.navigationBar.items![0].title = dict[17]![LANG]
		navigationItem.setHidesBackButton(true, animated: false)
		navigationItem.setHidesBackButton(false, animated: false)
		
		// язык таб-иконок
		if let customTabBarController = tabBarController as? TabBarController {
			customTabBarController.switchTabTitles(for: UIScreen.main.bounds.size)
		}
		// язык дат в сообщениях
		let messagesController = tabBarController?.viewControllers![0].children.first as! MessagesController
		messagesController.tableView.reloadData()
		
	}
	
	
}






class LangCell: UITableViewCell {
	
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		accessoryType = selected ? .checkmark : .none
	}
	
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}











