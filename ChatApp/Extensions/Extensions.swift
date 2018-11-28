//
//  Extensions.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 01.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

var imageCache = NSCache<NSString, UIImage>()




extension UIImageView {
    
    /// загрузчик картинок с внешних адресов (использует кэш)
    public func loadImageUsingCache(urlString: String, completionHandler: ((UIImage) -> ())? ){
        
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

        if urlString == "none"{ // если юзер не ставил фото на профиль, грузим дефолтную пикчу
            let img = UIImage(named: default_profile_image)!
            setImageForUIView(img)
            return
        }
        
        // проверяем нет ли запрашиваемой картинки в кэше
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            setImageForUIView(cachedImage)
            return
        }
        let downloadTask = URLSession.shared.dataTask(with: URL(string: urlString)!) {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    setImageForUIView(downloadedImage)
                }
            }
        }
        downloadTask.resume()
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
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
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
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        self.clipsToBounds = true
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}






























