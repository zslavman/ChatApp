//
//  UserCell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 07.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


// кастомизация стандартной ячейки таблицы (для того, чтоб иметь доступ к текстовому полю detailTextLabel)
class UserCell: UITableViewCell {
	

	// дефолтная фотка
	public let profileImageView:UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 26 // 20*2 - половина величины констрейнта
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	// тайм-лейбл
	private let timeLabel:UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12)
		label.textColor = UIColor.lightGray
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		return label
	}()
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		detailTextLabel?.textColor = .gray
		
		addSubview(profileImageView)
		addSubview(timeLabel)
		
		// constraints: x, y, width, height
		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive 	= true
		profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive 		= true
		profileImageView.widthAnchor.constraint(equalToConstant: 52).isActive 					= true
		profileImageView.heightAnchor.constraint(equalToConstant: 52).isActive 					= true
		
		timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive 	= true
		timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 22).isActive 			= true
		timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive 							= true
	}
	
	
	
	// фикс заeзжания текста под фотку профиля
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// подвигаем тайтл
		textLabel?.frame = CGRect(x: 72, y: textLabel!.frame.origin.y + 2, width: self.frame.width - 150, height: textLabel!.frame.height)
		// подвигаем емайл
		detailTextLabel?.frame = CGRect(x: 72, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 150, height: detailTextLabel!.frame.height)
	}
	
	
	
	/// настройка ячейки для MessagesController
	public func setupCell(msg:Message, indexPath:IndexPath){
		
		let ref = Database.database().reference().child("users").child(msg.chatPartnerID()!)
		
		ref.observeSingleEvent(of: .value, with: {
			(snapshot:DataSnapshot) in
			
			if let dictionary = snapshot.value as? [String:AnyObject]{
				// преобразовываем toID в реальное имя
				self.textLabel?.text = dictionary["name"] as? String
				
				// получаем картинку
				self.tag = indexPath.row // для идентификации ячейки в кложере
				
				if let profileImageUrl = dictionary["profileImageUrl"] as? String{
					// качаем картинку
					self.profileImageView.loadImageUsingCache(urlString: profileImageUrl){
						(image) in
						// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
						// и обновить ее в главном потоке
						DispatchQueue.main.async {
							if self.tag == indexPath.row{
								self.profileImageView.image = image
							}
						}
					}
				}
			}
		}, withCancel: nil)
		
		detailTextLabel?.text = msg.text
		
		if let seconds = msg.timestamp?.doubleValue{
			timeLabel.text = UserCell.timesAgo(seconds: seconds)
		}
		
	}
	

	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	
	/// Возвращает время или кол-во прошедшено времени (в разных форматах) относительно текущего времени
	/// - Parameter seconds: кол-во секунд прошедшее с 1970г
	public static func timesAgo(seconds:TimeInterval) -> String{
		
		let convertedDate = Date(timeIntervalSince1970: seconds)
		let dateFormater = DateFormatter()
		var returned:String = ""
		
		// сегодня
		if Calendar.current.isDateInToday(convertedDate){
			dateFormater.dateFormat = "HH:mm:ss"
			returned = dateFormater.string(from: convertedDate)
		}
		// вчера
		else if Calendar.current.isDateInYesterday(convertedDate){
			dateFormater.dateFormat = "HH:mm"
			returned = "вчера \n" + dateFormater.string(from: convertedDate)
		}
		// на этой неделе
		else if seconds + Double(604800) <= NSDate().timeIntervalSince1970 {
			returned = dateFormater.weekdaySymbols[Calendar.current.component(.weekday, from: convertedDate)]
		}
		// более недели назад
		else {
			dateFormater.dateFormat = "dd:MM:yy"
			returned = dateFormater.string(from: convertedDate)
		}
		
		return returned
	}
	
	
	

	
	
	
}


















