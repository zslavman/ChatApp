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
		var time = String(format:"%2i:%02i", min, sec)
		
		time.removeFirst()
		return time
	}
	
	
	
	
	/// Возвращает время или кол-во прошедшено времени (в разных форматах) относительно текущего времени
	/// - Parameters:
	///   - seconds: кол-во секунд прошедшее с 1970г
	///   - lessText: short text
	///   - shouldReturn: нужно ли делать перенос на след. строку
	public static func convertTimeStamp(seconds: TimeInterval, lessText: Bool, shouldReturn: Bool = true) -> String{
		let convertedDate = Date(timeIntervalSince1970: seconds)
		let dateFormater = DateFormatter()
		dateFormater.locale = Locale(identifier: dict[24]![LANG])
		var caretSymbol: String = "\n"
		if !shouldReturn {
			caretSymbol = " "
		}
		
		dateFormater.dateFormat = "HH:mm"
		let HH_mm = dateFormater.string(from: convertedDate)
		if lessText {
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
	
	
	public static func timesAgoDisplay(timeinterval: TimeInterval) -> String {
		let date = Date(timeIntervalSince1970: timeinterval)
		let secondsAgo = Int(Date().timeIntervalSince(date))
		
		let minute = 60
		let hour = 60 * minute
		let day = 24 * hour
		
		let quotient: Int
		let unit: String
		
		if secondsAgo < minute {
			quotient = max(1, secondsAgo)
			unit = dict[53]![LANG] // c
		}
		else if secondsAgo < hour {
			quotient = secondsAgo / minute
			unit = dict[54]![LANG] // мин.
		}
		else if secondsAgo < day && secondsAgo <= 4 * hour {
			quotient = secondsAgo / hour
			unit = dict[55]![LANG] // час.
		}
		else {
			return convertTimeStamp(seconds: timeinterval, lessText: false, shouldReturn: false)
		}
		return "\(quotient) \(unit) \(dict[56]![LANG])" // назад
	}
	
	
	
	/// подсчет ожидаемых размеров текстового поля
	static func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: UIScreen.main.bounds.width * 2/3, height: .infinity)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
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
	
	
	
	public static func gatherDeviceInfo() -> [String]{
		
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
	
	
	
	
	static func alert(message: String, title: String = "", completion: (() -> ())?) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let OK_action = UIAlertAction(title: dict[38]![LANG], style: .default, handler: {
			(action) in
			if let completion = completion {
				completion()
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
	
	
	
	// измерение скорости выполнения методов
	static func timeMeasuringCodeRunning(title:String, operationBlock: () -> ()) {
		let start = CFAbsoluteTimeGetCurrent()
		operationBlock()
		let finish = CFAbsoluteTimeGetCurrent()
		let timeElapsed = finish - start
		print ("Время выполнения \(title) = \(timeElapsed) секунд")
	}
	
	
	
	
	
	// откроется в другом потоке т.к. URLSession
	static func getJSON(link: String, completion: @escaping (Data) -> Void){
		var url: URL
		// проверяем валидность урл
		if let validLink = URL(string: link){
			url = validLink
		}
		else {
			print("Invalid link!")
			return
		}
		URLSession.shared.dataTask(with: url) {
			(data, response, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			else if let data = data {
				print("Got new JSON")
				completion(data)
			}
		}.resume()
	}
	
	
	
	public static func linkParser (url: URL) -> [String:String] {
		var dict = [String:String]()
		let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		if let queryItems = components.queryItems {
			for item in queryItems {
				dict[item.name] = item.value!
			}
		}
		return dict
	}
	
	
	public static func printDictionary(dict:[String:Any]) {
		dict.forEach { print("\($0.key) = \($0.value)")}
	}
	
	
	
	/// Возвращает рандомный элемент массива
	///
	/// - Parameter arr: массив
	public static func randArrElemen<T>(array arr:Array<T>) -> T{
		
		let randomIndex = Int(arc4random_uniform(UInt32(arr.count)))
		return arr[randomIndex]
	}
	
	/// Возвращает рандомное число между min и max
	public static func random(_ min: Int, _ max: Int) -> Int {
		guard min < max else {return min}
		return Int(arc4random_uniform(UInt32(1 + max - min))) + min
	}
	
	
	// расстояние между дкумя точками
	public func distanceCalc(a:CGPoint, b:CGPoint) -> CGFloat{
		return sqrt(pow((b.x - a.x), 2) + pow((b.y - a.y), 2))
	}
	
	// пересчет времени передвижения при различных расстояниях
	public func timeToTravelDistance(distance:CGFloat, speed:CGFloat) -> TimeInterval{
		let time = distance / speed
		return TimeInterval(time)
	}
	
	
	// получение текущего DateComponents
	public static func getDateComponent(fromDate:Date = Date()) -> DateComponents{
		let calendar = Calendar(identifier: .gregorian)
		let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: fromDate)
		
		return components
	}
	
	
	
	
}

























