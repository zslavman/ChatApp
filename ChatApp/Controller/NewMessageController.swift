//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 31.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

	private var cellID = "cellID"
	private var users = [User]()
	public var messagesController:MessagesController?
	private var timer:Timer? // таймер-задержка перезагрузки таблицы
	
	let arr = [
		"А":["Андрей", "Алексей", "Аня"],
		"Б":["Боря", "Богдан"],
		"В":["Витя", "Вова", "Владик"]
	]
	private var twoD = [[String]]()
	
	private var temp = [String : [String]]()
	private var letter = [String]()
	
	
	
	
	
	private func prepareData(){
		// создаем массив букв (без повтора)
		for value in users {
			let char = value.name?.prefix(1).uppercased()
			if !letter.contains(char!){
				letter.append(char!)
				twoD.append([])
			}
			letter.sort()
		}
		print("letter = \(letter)")
		
		// заполняем массив массивов юзеров, согласно алфавита
		for value in users {
			let char = value.name?.prefix(1).uppercased()
			let index = letter.index(of: char!)
			twoD[index!].append(value.name!)
		}
		print("twoD = \(twoD)")
		
		// сортируем элементы каждого внутреннего массива
		for var value in twoD {
			value.sort{$0.localizedCaseInsensitiveCompare($1) == .orderedAscending}
		}
		
		print("twoD = \(twoD)")
		
		
//		let temp2 = temp.sorted {
//			// key1: (key: String, value: [String])
//			(key1, key2) -> Bool in
//			return key1.key.localizedCaseInsensitiveCompare(key2.key) == .orderedAscending
//		}

	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.title = "Все юзеры"

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(onCancelClick))
		tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
		fetchUsers()
	}
	

	

	private func fetchUsers(){
		
		let ref = Database.database().reference(withPath: "users")
		ref.observe(.childAdded, with: { // по сути - это цикл
			(snapshot) in
			
			if let dict = snapshot.value as? [String:AnyObject]{
				let user = User()
				// крашанет если в классе не найдется переменных с именами ключей словаря
				user.setValuesForKeys(dict)
				self.users.append(user)
			}
			self.attemptReloadofTable()
		}, withCancel: nil)
	}
	
	
	
	
	private func attemptReloadofTable(){
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.delayedRelodTable), userInfo: nil, repeats: false)
	}
	
	/// (без этого таблица перезагружается десятки раз)
	@objc private func delayedRelodTable(){
		users.sort{$0.email!.localizedCaseInsensitiveCompare($1.email!) == .orderedAscending}
		DispatchQueue.main.async {
			self.prepareData()
			self.tableView.reloadData()
		}
	}
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	

	@objc private func onCancelClick(){
		dismiss(animated: true, completion: nil)
	}
	
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return users.count
	}
	
	
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
		
		let user = users[indexPath.row]
		cell.textLabel?.text = user.name
		cell.detailTextLabel?.text = user.email
		cell.tag = indexPath.row // для идентификации ячейки в кложере

		if let profileImageUrl = user.profileImageUrl{
			// качаем картинку
			cell.profileImageView.loadImageUsingCache(urlString: profileImageUrl){
				(image) in
				// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
				// и обновить ее в главном потоке
				DispatchQueue.main.async {
					if cell.tag == indexPath.row{
						cell.profileImageView.image = image
					}
				}
			}
		}
		
		return cell
	}
	
	
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72.0
	}
	
	
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dismiss(animated: true) {
			// дожидаемся окончания убивания этого контроллера и в контроллере-родителе запускаем ф-цию goToChat()
			let user = self.users[indexPath.row]
			self.messagesController?.goToChatWith(user: user)
		}
	}
	
	
	
}


















