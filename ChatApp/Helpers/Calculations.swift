//
//  Calculations.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 02.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import Foundation
import Firebase


struct Calculations {
	
	
	
	/// выдирает ключи из снапшота в строковый массив
	static func extractKeysToArray(snapshot:[DataSnapshot]) -> [String]{
		
		var keyStrings = [String]()
		
		for child in snapshot {
			let nam = child.key
			keyStrings.append(nam)
		}
		keyStrings = snapshot.map({$0.key})
		
		return keyStrings
	}
	
	
	
	/// получаем класс со строки
	static func stringClassFromString(className: String) -> AnyClass! {
		
		/// get namespace
		let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
		
		let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!
		
		return cls
	}
	
	
	
	
	/// преобразования даты для секций колекшнвью
	static func gatheringData(seconds:TimeInterval) -> String{
		
		let convertedDate = Date(timeIntervalSince1970: seconds)
		let dateFormater = DateFormatter()
		dateFormater.locale = Locale(identifier: dict[24]![LANG]) // локаль (ru_US)
		
		// сегодня
		if Calendar.current.isDateInToday(convertedDate){
			return dict[23]![LANG] // сегодня
		}
			// вчера
		else if Calendar.current.isDateInYesterday(convertedDate){
			return dict[22]![LANG] // вчера
		}
			// на этой неделе (пятница)
		else if seconds + Double(604800) >= NSDate().timeIntervalSince1970 {
			var weekDayNum = Calendar.current.component(.weekday, from: convertedDate) - 1 // возвращает дни, начиная с 1
			if weekDayNum == 7 {
				weekDayNum = 0 // т.к. Вс - это 0-вой элемент массива
			}
			let weekDay = dateFormater.weekdaySymbols[weekDayNum]
			return weekDay
		}
			// более недели назад (03 Окт)
		else {
			dateFormater.dateFormat = "dd"
			let numDay = dateFormater.string(from: convertedDate)
			var month = dateFormater.shortMonthSymbols[Calendar.current.component(.month, from: convertedDate) - 1]
			if month.last == "."{
				month = String(month.dropLast())
			}
			return numDay + " " + month
		}
	}
	
	
	
	
	/// преобразует секунды в формат ММ:СС
	static func convertTime(seconds:Double) -> String{
		let intValue = Int(seconds)
		// let hou = intValue / 3600
		let min = intValue / 60
		let sec = intValue % 60
		let time = String(format: "%2i:%02i", min, sec)
		
		return time
	}
	
	
	
	
	/// Возвращает время или кол-во прошедшено времени (в разных форматах) относительно текущего времени
	/// - Parameters:
	///   - seconds: кол-во секунд прошедшее с 1970г
	///   - shouldReturn: нужно ли делать перенос на след. строку
	public static func convertTimeStamp(seconds:TimeInterval, shouldReturn:Bool) -> String{
		
		let convertedDate = Date(timeIntervalSince1970: seconds)
		let dateFormater = DateFormatter()
		dateFormater.locale = Locale(identifier: dict[24]![LANG])
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
			return dict[22]![LANG] + caretSymbol + HH_mm // вчера
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
	
	
	
	
	/// подсчет ожидаемых размеров текстового поля
	static func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: UIScreen.main.bounds.width * 2/3, height: .infinity)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	
	
	
	static func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
	
	
	static func gatherDeviceInfo() -> [String]{
		
		var returnedArr = [String]()
		
		let plistDictionary = Bundle.main.infoDictionary!
		let appVersion = plistDictionary["CFBundleShortVersionString"] as! String
		let build = plistDictionary["CFBundleVersion"] as! String
		let fullVersion = dict[41]![0] + " v." + appVersion + " build " + build
		
		returnedArr.append(fullVersion)
		
		returnedArr.append(UIDevice.current.modelName)
		returnedArr.append(UIDevice.current.systemName + " " + UIDevice.current.systemVersion)
		return returnedArr
	}
	
	
	
	static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
		if let delegate = UIApplication.shared.delegate as? AppDelegate {
			delegate.orientationLock = orientation
		}
	}
	
	/// OPTIONAL Added method to adjust lock and rotate to the desired orientation
	static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
		Calculations.lockOrientation(orientation)
		UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
	}
	
	
	
	
	static func alert(message: String, title: String = "", OK_action: (() -> ())?) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let OK_action = UIAlertAction(title: dict[38]![LANG], style: .default, handler: {
			(action) in
			if let OK_action = OK_action {
				OK_action()
			}
		})
		
		alertController.addAction(OK_action)
		return alertController
	}
	
	
	
	// анимированное появление таблицы без секций (ячейки подтягиваются снизу)
	static func animateTableWithRows(tableView:UITableView, duration: Double){
		
		let cells = tableView.visibleCells
		
		for cell in cells {
			cell.transform = CGAffineTransform(translationX: 0, y: tableView.bounds.size.height)
		}
		
		for (i, cell) in cells.enumerated() {
			let delay = Double(i) * 0.05
			UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
				cell.transform = CGAffineTransform.identity
			}, completion: nil)
		}
	}
	
	
	
	/// анимированное появление таблицы с секциями
	static func animateTableWithSections(tableView:UITableView){
		let range = NSMakeRange(0, tableView.numberOfSections)
		let sections = NSIndexSet(indexesIn: range)
		tableView.reloadSections(sections as IndexSet, with: .bottom)
	}
	
	
	
	
	static func timeMeasuringCodeRunning(title:String, operationBlock: () -> ()) {
		let start = CFAbsoluteTimeGetCurrent()
		operationBlock()
		let finish = CFAbsoluteTimeGetCurrent()
		let timeElapsed = finish - start
		print ("Время выполнения \(title) = \(timeElapsed) секунд")
	}
	
	
	
	
	
	
	
	
}

























