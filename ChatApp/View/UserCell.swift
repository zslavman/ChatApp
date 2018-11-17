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
	public var iTag:String!
	
	
	
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
		
		// от этой штуки надо избавиться, при прокурутке, юзеры каждый раз загружаются по-новому т.к. они нигде не сохраняются
		// Только после того как зайти в NewMessageController (где они сохраняются в [Users]) MessagesController работает без тормозов
		// TODO: загрузить изначально данные всех юзеров (с которыми диалоги), а сюда подавать готового юзера
		
		///******************************************
		let ref = Database.database().reference().child("users").child(msg.chatPartnerID()!)
		
		ref.observeSingleEvent(of: .value, with: {
			(snapshot:DataSnapshot) in

			if let dictionary = snapshot.value as? [String:AnyObject]{
				// преобразовываем toID в реальное имя
				self.textLabel?.text = dictionary["name"] as? String

				// получаем картинку
				self.iTag = (indexPath.section).description + (indexPath.row).description // для идентификации ячейки в кложере
				let basePath = self.iTag

				if let profileImageUrl = dictionary["profileImageUrl"] as? String{
					// качаем картинку
					self.profileImageView.loadImageUsingCache(urlString: profileImageUrl){
						(image) in
						// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
						// и обновить ее в главном потоке
						DispatchQueue.main.async {
//							print("self.iTag == basePath = \(self.iTag == basePath)")
							if self.iTag == basePath {
								self.profileImageView.image = image
							}
						}
					}
				}
			}
		}, withCancel: nil)
		///******************************************
		
		
		let str:String?
		if msg.text != nil {
			str = msg.text
		}
		else if msg.videoUrl != nil {
			str = "[видео]"
		}
		else {
			str = "[картинка]"
		}
		
		detailTextLabel?.text = str
		
		if let seconds = msg.timestamp?.doubleValue{
			timeLabel.text = UserCell.convertTimeStamp(seconds: seconds, shouldReturn: true)
		}
		
	}
	

	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		iTag = ""
		profileImageView.image = nil
	}
	
	
	/// Возвращает время или кол-во прошедшено времени (в разных форматах) относительно текущего времени
	/// - Parameters:
	///   - seconds: кол-во секунд прошедшее с 1970г
	///   - shouldReturn: нужно ли делать перенос на след. строку
	public static func convertTimeStamp(seconds:TimeInterval, shouldReturn:Bool) -> String{
		
		let convertedDate = Date(timeIntervalSince1970: seconds)
		let dateFormater = DateFormatter()
		let caretSymbol:String = shouldReturn ? "\n" : " "
		
		dateFormater.dateFormat = "HH:mm"
		let HH_mm = dateFormater.string(from: convertedDate)
		
		// сегодня (12:54)
		if Calendar.current.isDateInToday(convertedDate){
			return HH_mm
		}
		// вчера (вчера 18:36)
		else if Calendar.current.isDateInYesterday(convertedDate){
			return "вчера" + caretSymbol + HH_mm
		}
		// на этой неделе (Fri, 20:54)
		else if seconds + Double(604800) >= NSDate().timeIntervalSince1970 {
			let weekDay = dateFormater.shortWeekdaySymbols[Calendar.current.component(.weekday, from: convertedDate)]
			return weekDay + caretSymbol + HH_mm
		}
		// более недели назад (03 Oct, 12:47)
		else {
			dateFormater.dateFormat = "dd"
			let numDay = dateFormater.string(from: convertedDate)
			var month = dateFormater.shortMonthSymbols[Calendar.current.component(.month, from: convertedDate)]
			if month.last == "."{
				month = String(month.dropLast())
			}
			return numDay + " " + month + caretSymbol + HH_mm
		}
	}
	
	
	

	
	
	
}


















