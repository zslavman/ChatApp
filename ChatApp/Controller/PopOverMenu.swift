//
//  PopOverMenu.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 26.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

protocol PopoverMunuClickedDelegate:class { // class позволяет использовать слабую ссылку делегата
	func cellClicked(numberOfMenu: Int)
}



class PopOverMenu: UITableViewController {
	
	private var menuChapterNames = [String]()
	private let cell_ID = "cell_ID"
	weak open var popoverMunuClickedDelegate: PopoverMunuClickedDelegate?
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let str = MessagesController.shared.isOnline ? "Set offline" : "Set online"
		menuChapterNames = ["Reload table", str, "Bot enable"]
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cell_ID)
		tableView.isScrollEnabled = false
		
		// делаем разделитель ячеек на всю ширину таблицы
		self.tableView.separatorInset = UIEdgeInsets.zero
		self.tableView.layoutMargins = UIEdgeInsets.zero
	}
	
	
	
	override func viewWillLayoutSubviews() {
		preferredContentSize = CGSize(width: 130, height: tableView.contentSize.height)
	}
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuChapterNames.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cell_ID, for: indexPath)
		cell.textLabel?.text = menuChapterNames[indexPath.row]
		cell.textLabel?.textAlignment = .right
		
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		popoverMunuClickedDelegate?.cellClicked(numberOfMenu: indexPath.row)
		tableView.deselectRow(at: indexPath, animated: true)
		self.dismiss(animated: false, completion: nil)
	}
	
	
	
	
}

























