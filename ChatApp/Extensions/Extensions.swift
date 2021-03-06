//
//  Extensions.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 01.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Kingfisher


// var imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
	
	//		let cache = ImageCache.default
	//		cache.clearMemoryCache()
	//		cache.clearDiskCache { print("Done") }

    /// загрузчик картинок с внешних адресов (использует кэш)
	public func loadImageUsingCache(urlString: String, isAva:Bool = false, completionHandler: ((UIImage) -> ())? ){
        /// внутренняя подфункция проверяющая есть ли колбэк
        func setImageForUIView(_ gotImage:UIImage){
            if let completionHandler = completionHandler { // если есть колбэк - вызываем его
                completionHandler(gotImage)
            }
            else {
                DispatchQueue.main.async {
                    self.image = gotImage
                }
            }
        }
        //*******************************

		let placeholderAva = UIImage(named: default_profile_image)!
		let placeholderNotAva = SUtils.getImageWithColor(color: #colorLiteral(red: 0.737254902, green: 0.768627451, blue: 0.8509803922, alpha: 1), size: CGSize(width: 20, height: 20))
		
		if urlString == "none"{ // если юзер не ставил фото на профиль, грузим дефолтную пикчу
            setImageForUIView(placeholderAva)
            return
        }
		
		let url = URL(string: urlString)
		let placeholder = (isAva) ? placeholderAva : placeholderNotAva
		self.kf.setImage(with: url, placeholder: placeholder)
		
        // проверяем нет ли запрашиваемой картинки в кэше
//        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
//            setImageForUIView(cachedImage)
//            return
//        }
//        let downloadTask = URLSession.shared.dataTask(with: URL(string: urlString)!) {
//            (data, response, error) in
//            if error != nil {
//                print(error!.localizedDescription)
//                return
//            }
//            DispatchQueue.main.async {
//                if let downloadedImage = UIImage(data: data!){
//                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
//                    setImageForUIView(downloadedImage)
//                }
//            }
//        }
//        downloadTask.resume()
    }
    
}



// устранение проблемы потери фоновой заливки во всех UIView ячейки таблицы при didSelectRow
class NeverClearView:UIView {
    
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != nil && backgroundColor!.cgColor.alpha == 0 {
                backgroundColor = oldValue
            }
        }
    }
}



// кастомная лейба, в которой можно установить паддинги
class UILabelWithEdges: UILabel {
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}



// прокрутка UICollectionView вниз
extension UICollectionView {
    
    func scrollToLast(animated:Bool) {
        guard numberOfSections > 0 else { return }
        let lastSection = numberOfSections - 1
        guard numberOfItems(inSection: lastSection) > 0 else { return }
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: animated)
    }
    
}




extension UIColor {
    
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}



// определение активного текст. поля
extension UIView {
    
    var currentFirstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.currentFirstResponder {
                return firstResponder
            }
        }
        return nil
    }
}



// цвет клика по кнопке
extension UIButton {
	
	public func customizeSignInButton(btnWidth: CGFloat, backColor: UIColor, title: String, titleColor: UIColor, imageIcon: UIImage) {
		backgroundColor = backColor
		setTitle(title, for: .normal)
		titleEdgeInsets.right = 5
		setImage(imageIcon, for: .normal)
		imageView?.contentMode = .scaleAspectFit
		let titleWidth = titleLabel?.sizeThatFits(CGSize(width: 0, height: 20)).width ?? 0
		imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: btnWidth - 42 - titleWidth)
		//contentHorizontalAlignment = .left
		//semanticContentAttribute = .forceLeftToRight
		setTitleColor(titleColor, for: .normal)
		titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		translatesAutoresizingMaskIntoConstraints = false
		
		layer.cornerRadius = 8
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 3
		layer.shadowOpacity = 0.15
		adjustsImageWhenHighlighted = false
	}
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
	
	func setIconAndTitle(title: String, icon: UIImage, widthConstraints: NSLayoutConstraint) {
		self.setTitle(title, for: .normal)
		self.setTitle(title, for: .highlighted)
		self.setTitleColor(UIColor.white, for: .normal)
		self.setTitleColor(UIColor.white, for: .highlighted)
		self.setImage(icon, for: .normal)
		self.setImage(icon, for: .highlighted)
		let imageWidth = self.imageView!.frame.width
		let textWidth = (title as NSString).size(withAttributes:[NSAttributedString.Key.font: self.titleLabel!.font!]).width
		let width = textWidth + imageWidth + 24 //24 - the sum of your insets from left and right
		widthConstraints.constant = width
		self.layoutIfNeeded()
	}

}




extension UIView {
	
	var safeTopAnchor: NSLayoutYAxisAnchor {
		if #available(iOS 11.0, *) {
			return self.safeAreaLayoutGuide.topAnchor
		} else {
			return self.topAnchor
		}
	}
	var safeLeftAnchor: NSLayoutXAxisAnchor {
		if #available(iOS 11.0, *){
			return self.safeAreaLayoutGuide.leftAnchor
		} else {
			return self.leftAnchor
		}
	}
	var safeRightAnchor: NSLayoutXAxisAnchor {
		if #available(iOS 11.0, *){
			return self.safeAreaLayoutGuide.rightAnchor
		} else {
			return self.rightAnchor
		}
	}
	var safeBottomAnchor: NSLayoutYAxisAnchor {
		if #available(iOS 11.0, *) {
			return self.safeAreaLayoutGuide.bottomAnchor
		} else {
			return self.bottomAnchor
		}
	}
}


	

class SearchController: UISearchController {
	
	override func viewWillDisappear(_ animated: Bool) {
		// to avoid black screen when switching tabs while searching
		isActive = false
		super.viewWillDisappear(animated)
	}
}


class UnselectableTextView: UITextView {
	
//	override public var selectedTextRange: UITextRange? {
//		get { return nil }
//		set { }
//	}
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

		guard let pos = closestPosition(to: point), let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: convertToUITextDirection(UITextLayoutDirection.left.rawValue)) else {
			return false
		}
		let startIndex = offset(from: beginningOfDocument, to: range.start)
		return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
	}
}




extension UIDevice {
	
	/// pares the deveice name as the standard name
	public var modelName: String {
		
		#if targetEnvironment(simulator)
		let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
		#else
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") {
			(identifier, element) in
			guard let value = element.value as? Int8 , value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		#endif
		
		switch identifier {
		case "iPod5,1":                                 return "iPod Touch 5"
		case "iPod7,1":                                 return "iPod Touch 6"
		case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
		case "iPhone4,1":                               return "iPhone 4s"
		case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
		case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
		case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
		case "iPhone7,2":                               return "iPhone 6"
		case "iPhone7,1":                               return "iPhone 6 Plus"
		case "iPhone8,1":                               return "iPhone 6s"
		case "iPhone8,2":                               return "iPhone 6s Plus"
		case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
		case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
		case "iPhone8,4":                               return "iPhone SE"
		case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
		case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
		case "iPhone10,3", "iPhone10,6":                return "iPhone X"
		case "iPhone11,2":                              return "iPhone XS"
		case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
		case "iPhone11,8":                              return "iPhone XR"
		case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
		case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
		case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
		case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
		case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
		case "iPad6,11", "iPad6,12":                    return "iPad 5"
		case "iPad7,5", "iPad7,6":                      return "iPad 6"
		case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
		case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
		case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
		case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
		case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
		case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
		case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
		case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
		case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
		case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
		case "AppleTV5,3":                              return "Apple TV"
		case "AppleTV6,2":                              return "Apple TV 4K"
		case "AudioAccessory1,1":                       return "HomePod"
		default:                                        return identifier
		}
	}
}

// сколько времени прошло
extension Date {
	
	func timesAgoDisplay() -> String {
		let secondsAgo = Int(Date().timeIntervalSince(self))
		
		let minute = 60
		let hour = 60 * minute
		let day = 24 * hour
		let week = 7 * day
		let month = 4 * week
		
		let quotient:Int
		let unit:String
		
		if secondsAgo < minute {
			quotient = secondsAgo
			unit = "second"
		}
		else if secondsAgo < hour {
			quotient = secondsAgo / minute
			unit = "min"
		}
		else if secondsAgo < day {
			quotient = secondsAgo / hour
			unit = "hour"
		}
		else if secondsAgo < week {
			quotient = secondsAgo / day
			unit = "day"
		}
		else if secondsAgo < month {
			quotient = secondsAgo / week
			unit = "week"
		}
		else {
			quotient = secondsAgo / month
			unit = "month"
		}
		return "\(quotient) \(unit)\(quotient == 1 ? "": "s") ago"
	}
}


extension UIImage {
	
	func imageWithColor(color1: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		color1.setFill()
		let context = UIGraphicsGetCurrentContext()
		context?.translateBy(x: 0, y: self.size.height)
		context?.scaleBy(x: 1.0, y: -1.0)
		context?.setBlendMode(CGBlendMode.normal)
		let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
		context?.clip(to: rect, mask: self.cgImage!)
		context?.fill(rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage!
	}
	
	func tint(with color: UIColor) -> UIImage {
		var image = withRenderingMode(.alwaysTemplate)
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		color.set()
		
		image.draw(in: CGRect(origin: .zero, size: size))
		image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
}


extension UIViewController {
	func setStatusBarStyle(_ style: UIStatusBarStyle) {
		if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
			//statusBar.backgroundColor = style == .lightContent ? UIColor.black : .white
			statusBar.setValue(style == .lightContent ? UIColor.white : .black, forKey: "foregroundColor")
		}
	}
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUITextDirection(_ input: Int) -> UITextDirection {
	return UITextDirection(rawValue: input)
}
