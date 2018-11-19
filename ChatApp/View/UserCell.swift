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
	

	public static let onLineColor = UIColor(r: 0, g: 255, b: 0)
	public static let offLineColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	
	// дефолтная фотка
	public let profileImageView:UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 26 // половина величины констрейнта ширины
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	public let onlinePoint:UIView = {
		let point = UIView()
		point.backgroundColor = offLineColor
		point.layer.cornerRadius = 6
		point.layer.masksToBounds = true
		point.layer.borderWidth = 2
		point.layer.borderColor = UIColor.white.cgColor
		point.translatesAutoresizingMaskIntoConstraints = false
		return point
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
		addSubview(onlinePoint)
		
		// constraints: x, y, width, height
		profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive 	= true
		profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive 		= true
		profileImageView.widthAnchor.constraint(equalToConstant: 52).isActive 					= true
		profileImageView.heightAnchor.constraint(equalToConstant: 52).isActive 					= true
		
		timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive 	= true
		timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 22).isActive 			= true
		timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive 							= true
		
		onlinePoint.centerXAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: -2).isActive = true
		onlinePoint.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -8).isActive = true
		onlinePoint.widthAnchor.constraint(equalToConstant: 12).isActive = true
		onlinePoint.heightAnchor.constraint(equalToConstant: 12).isActive = true
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
	public func setupCell(msg:Message, indexPath:IndexPath, user:User){ // user - не владелец
		
		textLabel?.text = user.name
		
		if user.isOnline {
			onlinePoint.backgroundColor = UserCell.onLineColor
		}
		else {
			onlinePoint.backgroundColor = UserCell.offLineColor
		}
		
		
		let basePath = (indexPath.section).description + (indexPath.row).description // для идентификации ячейки в кложере
		
		if let profileImageUrl = user.profileImageUrl{
			// качаем картинку
			self.profileImageView.loadImageUsingCache(urlString: profileImageUrl){
				(image) in
				// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
				// и обновить ее в главном потоке
				DispatchQueue.main.async {
					if self.iTag == basePath {
						self.profileImageView.image = image
					}
				}
			}
		}
		
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
//		profileImageView.image = nil
	}
	
	
	/// Возвращает время или кол-во прошедшено времени (в разных форматах) относительно текущего времени
	/// - Parameters:
	///   - seconds: кол-во секунд прошедшее с 1970г
	///   - shouldReturn: нужно ли делать перенос на след. строку
	public static func convertTimeStamp(seconds:TimeInterval, shouldReturn:Bool) -> String{
		
		let convertedDate = Date(timeIntervalSince1970: seconds)
		let dateFormater = DateFormatter()
		let caretSymbol:String = "\n"
		
		dateFormater.dateFormat = "HH:mm"
		let HH_mm = dateFormater.string(from: convertedDate)
		if !shouldReturn{
			return HH_mm
		}
		
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
			var weekDayNum = Calendar.current.component(.weekday, from: convertedDate) - 1 // возвращает дни, начиная с 1
			if weekDayNum == 7 {
				weekDayNum = 0 // т.к. Вс - это 0-вой элемент массива
			}
			let weekDay = dateFormater.shortWeekdaySymbols[weekDayNum]
			return weekDay + caretSymbol + HH_mm
		}
		// более недели назад (03 Oct, 12:47)
		else {
			dateFormater.dateFormat = "dd"
			let numDay = dateFormater.string(from: convertedDate)
			var month = dateFormater.shortMonthSymbols[Calendar.current.component(.month, from: convertedDate) - 1]
			if month.last == "."{
				month = String(month.dropLast())
			}
			return numDay + " " + month + caretSymbol + HH_mm
		}
	}
	
	
	

	
	
	
}


















