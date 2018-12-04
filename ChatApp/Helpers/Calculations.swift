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
		
		// сегодня
		if Calendar.current.isDateInToday(convertedDate){
			return "сегодня"
		}
			// вчера
		else if Calendar.current.isDateInYesterday(convertedDate){
			return "вчера"
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
	
	
	
	
	/// подсчет ожидаемых размеров текстового поля
	static func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: UIScreen.main.bounds.width * 2/3, height: .infinity)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	
	
	
	
	
}








