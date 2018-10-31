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
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancelClick))
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
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
			
			
		}, withCancel: nil)
	}
	
	

	@objc private func onCancelClick(){
		dismiss(animated: true, completion: nil)
	}
	
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return users.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// для того, чтоб иметь доступ к текстовому полю detailTextLabel
//		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		
		let user = users[indexPath.row]
		cell.textLabel?.text = user.name
		cell.detailTextLabel?.text = user.email
		
		return cell
	}
	
}




// кастомизация стандартной ячейки таблицы
class UserCell: UITableViewCell {
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

















