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
				user.id = snapshot.key // это и есть юзерID
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




// кастомизация стандартной ячейки таблицы (для того, чтоб иметь доступ к текстовому полю detailTextLabel)
class UserCell: UITableViewCell {
	
	// фотка по дефолту
	public let profileImageView:UIImageView = {
		let imageView = UIImageView()
//		imageView.image = UIImage(named: "default_profile_image") // default pic
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 26 // 20*2 - половина величины констрейнта
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		addSubview(profileImageView)
		// constraints: x, y, width, height
		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
		profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 52).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 52).isActive = true
	}
	
	
	// фикс заeзжания текста под картинку
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// подвигаем тайтл
		textLabel?.frame = CGRect(x: 72, y: textLabel!.frame.origin.y + 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
		// подвигаем емайл
		detailTextLabel?.frame = CGRect(x: 72, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
	}
	
	
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		profileImageView.image = nil
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

















