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
	
	// фотка
	public let profileImageView:UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "default_profile_image") // дефолтная фотка
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 26 // половина величины констрейнта ширины
		imageView.layer.borderWidth = 0.6
		imageView.layer.borderColor = offLineColor.cgColor
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	public let onlinePoint:NeverClearView = {
		let point = NeverClearView()
		point.backgroundColor = offLineColor
		point.layer.cornerRadius = 6
		point.layer.borderWidth = 2
		point.layer.borderColor = UIColor.white.cgColor
		point.layer.masksToBounds = true
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
	
	public let newMessBack:NeverClearView = {
		let point = NeverClearView()
		point.backgroundColor = .red
		point.layer.cornerRadius = 9
		point.layer.borderWidth = 2
		point.layer.borderColor = UIColor.white.cgColor
		point.layer.masksToBounds = true
		point.translatesAutoresizingMaskIntoConstraints = false
		point.isHidden = true
		return point
	}()
	
	public let newMessCount:UILabel = {
		let label = UILabel()
		label.text = "0"
//		label.adjustsFontSizeToFitWidth = true
		label.font = UIFont.boldSystemFont(ofSize: 12)
		label.textColor = UIColor.white
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	
	public var iTag:String!
	public var userID:String? // для идентификации, кто сейчас в ячейке
	
	
	
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		detailTextLabel?.textColor = .gray
		detailTextLabel?.backgroundColor = .red
		
		addSubview(profileImageView)
		addSubview(timeLabel)
		addSubview(onlinePoint)
		addSubview(newMessBack)
		newMessBack.addSubview(newMessCount)
		
		// constraints: x, y, width, height
		NSLayoutConstraint.activate([
			profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
			profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			profileImageView.widthAnchor.constraint(equalToConstant: 52),
			profileImageView.heightAnchor.constraint(equalToConstant: 52),
			
			timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
			timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 22),
			timeLabel.widthAnchor.constraint(equalToConstant: 70),
			
			onlinePoint.centerXAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: -2),
			onlinePoint.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -8),
			onlinePoint.widthAnchor.constraint(equalToConstant: 12),
			onlinePoint.heightAnchor.constraint(equalToConstant: 12),
			
			newMessBack.centerXAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: -2),
			newMessBack.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 8),
			newMessBack.widthAnchor.constraint(equalToConstant: 18),
			newMessBack.heightAnchor.constraint(equalToConstant: 18),
			
			newMessCount.centerXAnchor.constraint(equalTo: newMessBack.centerXAnchor),
			newMessCount.centerYAnchor.constraint(equalTo: newMessBack.centerYAnchor)
		])
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
		
		userID = user.id
		textLabel?.text = user.name
		
		if let count = msg.unreadCount, count > 0 {
			newMessBack.isHidden = false
			newMessCount.text = count.description
		}
		else {
			newMessBack.isHidden = true
		}
		
		if user.isOnline {
			onlinePoint.backgroundColor = UserCell.onLineColor
		}
		else {
			onlinePoint.backgroundColor = UserCell.offLineColor
		}
		
		
		let basePath = (indexPath.section).description + (indexPath.row).description // для идентификации ячейки в кложере
		
		if let profileImageUrl = user.profileImageUrl{
			// качаем картинку
			self.profileImageView.loadImageUsingCache(urlString: profileImageUrl, isAva: true){
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
			str = dict[29]![LANG] // "[видео]"
		}
		else if msg.imageUrl != nil{
			str = dict[30]![LANG] // "[картинка]"
		}
		else {
			str = dict[50]![LANG] // [гео]
		}
		
		detailTextLabel?.text = str
		
		if let seconds = msg.timestamp?.doubleValue{
			
			timeLabel.text = Calculations.convertTimeStamp(seconds: seconds, shouldReturn: true)
		}

	}
	

	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		iTag = ""
		// если оставить так, то после каждого обновлении таблицы фотки блымнут
		profileImageView.image = UIImage(named: "default_profile_image")
		newMessBack.isHidden = true
	}
	
	

	
}
























