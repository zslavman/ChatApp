//
//  MessagesController_Main.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 07.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


// нативные методы таблицы и контроллера
extension MessagesController {
	
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		goToChatWithID = nil
		// чтоб до viewDidLoad не отображалась дефолтная таблица
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.backgroundColor = UIColor.white
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		// перезагружаем ячейку по которой кликнули для обнуления кол-ва непрочит. сообщ.
//		if let savedIndexPath = savedIndexPath {
		if savedIndexPath != nil {
			reloadTable()
//			tableView.reloadRows(at: [savedIndexPath], with: .none)
			self.savedIndexPath = nil
		}
	}
	
	
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentList[section].cells.count
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return currentList.count
	}
	
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	
	/// то, что будет выполнено при нажатии на "удалить"
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		let message = currentList[0][indexPath.row]
		if let partnerID = message.chatPartnerID(){
			refUserMessages_original.child(uid).child(partnerID).removeValue {
				(error, ref) in
				if error != nil {
					print(error!.localizedDescription)
					return
				}
				
				self.removeDialog(collocutorID: partnerID, indexPath: indexPath)
			}
		}
	}
	

	
	
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as! UserCell
		let msg = currentList[0][indexPath.row]
		
		if msg.toID != nil {
			cell.iTag = (indexPath.section).description + (indexPath.row).description
			let basePath = cell.iTag
			let _id = msg.chatPartnerID()!
			var _user:User?
			
			// если юзер с _id есть в массиве senders, передаем его в setupCell
			for value in senders {
				if value.id == _id {
					_user = value
					break
				}
			}
			if let _user = _user {
				cell.setupCell(msg: msg, indexPath: indexPath, user: _user)
			}
				// если нет - загружаем его (данные)
			else {
				let ref = Database.database().reference().child("users").child(_id)
				
				ref.observeSingleEvent(of: .value, with: {
					(snapshot:DataSnapshot) in
					
					if let dictionary = snapshot.value as? [String:AnyObject]{
						
						let user = User()
						user.setValuesForKeys(dictionary)
						self.senders.append(user)
						
						if cell.iTag == basePath {
							cell.setupCell(msg: msg, indexPath: indexPath, user: user)
						}
					}
				})
			}
		}
		
		// цвет выделения при клике на ячейку
		let selectionColor = UIView()
		selectionColor.backgroundColor = ChatMessageCell.blueColor.withAlphaComponent(0.45)
		cell.selectedBackgroundView = selectionColor
		
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72.0
	}
	
	
	
	
	/// при клике на диалог (юзера)
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let messag = currentList[0][indexPath.row]
		
		// сначала обнуляем данные о непрочтенных, в viewDidDisappear обновим вьюшку
		messages[indexPath.row].unreadCount = nil
		savedIndexPath = indexPath
		
		guard let chatPartnerID = messag.chatPartnerID() else { return } 		// достаем ID юзера (кому собираемся писать)
		
		// достаем ссылку на юзера
		refUsers.child(chatPartnerID).observeSingleEvent(of: .value, with: {	// получаем юзера из БД
			(snapshot) in
			
			guard let dict = snapshot.value as? [String: AnyObject] else { return }
			
			let user = User()
			user.setValuesForKeys(dict)
			
			self.goToChatWith(user: user)
		})
	}
	
	
	
	
	
	

	
	
	
	
}




























