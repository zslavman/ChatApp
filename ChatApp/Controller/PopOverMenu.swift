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
	private var countDownTimer:Timer?
	private let timeCellDefText = "Notify me"
	private var sec:Double = 0 // заряд таймера
	
	private var timeTF:UILabel? { // текстовое поле пункта меню "Notify me"
		didSet{
			Notifications.shared.getLastNotifData {
				(seconds:Double) in
				DispatchQueue.main.async {
					self.timeTF?.text = "Notif (\(Calculations.convertTime(seconds: seconds)))"
					self.sec = seconds
					self.countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
				}
			}
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let str = MessagesController.shared.isOnline ? "Set offline" : "Set online"
		menuChapterNames = ["Reload table", str, "JSONTable", timeCellDefText]
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cell_ID)
		tableView.isScrollEnabled = false
		
		// делаем разделитель ячеек на всю ширину таблицы
		self.tableView.separatorInset = UIEdgeInsets.zero
		self.tableView.layoutMargins = UIEdgeInsets.zero
	}
	
	
	
	@objc private func timerTick(){
		sec -= 1
		if (sec <= 10){
			timeTF?.textColor = .red
		}
		if sec == 0 {
			countDownTimer?.invalidate()
			timeTF?.text = self.timeCellDefText
			timeTF?.textColor = .black
			return
		}
		let time = "Notif (\(Calculations.convertTime(seconds: sec)))"
		timeTF?.text = time
	}
	
	
	
	
	override func viewWillLayoutSubviews() {
		preferredContentSize = CGSize(width: 150, height: tableView.contentSize.height)
	}
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuChapterNames.count
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cell_ID, for: indexPath)
		cell.textLabel?.text = menuChapterNames[indexPath.row]
		cell.textLabel?.textAlignment = .right
		
		if indexPath.row == 3 {
			timeTF = cell.textLabel
		}
		
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		popoverMunuClickedDelegate?.cellClicked(numberOfMenu: indexPath.row)
		tableView.deselectRow(at: indexPath, animated: true)
		self.dismiss(animated: false, completion: nil)
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		countDownTimer?.invalidate()
	}
	
	

	
	
}

























