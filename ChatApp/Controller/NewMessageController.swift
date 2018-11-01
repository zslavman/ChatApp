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
			self.users.sort{$0.email!.localizedCaseInsensitiveCompare($1.email!) == .orderedAscending}
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
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
		
		let user = users[indexPath.row]
		cell.textLabel?.text = user.name
		cell.detailTextLabel?.text = user.email
		
		// качаем картинку
		if let profileImageUrl = user.profileImageUrl {
			let downloadTask = URLSession.shared.dataTask(with: URL(string: profileImageUrl)!) {
				(data, response, error) in
				if error != nil {
					print(error!.localizedDescription)
					return
				}
				DispatchQueue.main.async {
					cell.profileImageView.image = UIImage(data: data!)
 				}
			}
			downloadTask.resume()
		}
		
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 56.0
	}
	
	
	
	
}




// кастомизация стандартной ячейки таблицы (для того, чтоб иметь доступ к текстовому полю detailTextLabel)
class UserCell: UITableViewCell {
	
	// фотка по дефолту
	let profileImageView:UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "merlin") // default pic
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 20 // 20 - половина величины констрейнта
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		addSubview(profileImageView)
		// constraints: x, y, width, height
		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
		profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	
	// фикс зазжания текста под картинку
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// подвигаем тайтл
		textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y + 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
		// подвигаем емайл
		detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

















