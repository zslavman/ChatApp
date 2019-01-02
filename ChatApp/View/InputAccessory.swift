//
//  InputAccessory.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 18.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class InputAccessory: UIView, UITextViewDelegate {
	
    private let sendButton = UIButton(type: .system) // .system - для того, чтоб у кнопки были состояния нажатая/отжатая
    public var chatController:ChatController? {
        didSet{
            // sendButton.addTarget(chatLogController, action: #selector(chatLogController!.onSendClick), for: UIControlEvents.touchUpInside)
            sendButton.addTarget(self, action: #selector(onSend), for: UIControlEvents.touchUpInside)
            // uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onUploadClick)))
			uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatController, action: #selector(ChatController.onUploadClick)))
            insertGeo.addGestureRecognizer(UITapGestureRecognizer(target: chatController, action: #selector(ChatController.checkLocationAuthorization)))
        }
    }
    
    public lazy var inputTextField: UITextView = {
        let tf = UITextView()
        tf.text = dict[21]![0]
        tf.textColor = UIColor.lightGray
        tf.backgroundColor = .clear
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.returnKeyType = .send // всего лишь вид кнопки "Enter"
        tf.delegate = self
        tf.isScrollEnabled = false
//		tf.backgroundColor = UIColor.red.withAlphaComponent(0.2)
		tf.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		tf.layer.borderWidth = 1
		tf.layer.cornerRadius = 20
		tf.textContainer.lineFragmentPadding = 20
//		tf.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 10)
        return tf
    }()
    
    
    private let uploadImageView: UIImageView = {
        let uv = UIImageView()
        uv.image = UIImage(named: "upload_image_icon")
        uv.isUserInteractionEnabled = true
        uv.translatesAutoresizingMaskIntoConstraints = false
        return uv
    }()
	
	private let insertGeo: UIImageView = {
		let ig = UIImageView()
		ig.image = UIImage(named: "bttn_map_pin")?.withRenderingMode(.alwaysTemplate)
		ig.isUserInteractionEnabled = true
		ig.contentMode = .scaleAspectFit
		ig.translatesAutoresizingMaskIntoConstraints = false
		ig.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
		return ig
	}()
   
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	
	
	// adding the bottom constraint here to make sure we belong to window
	override func didMoveToWindow() {
		super.didMoveToWindow()
		if #available(iOS 11.0, *) {
//			if let window = window {
//				bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
//			}
		}
	}
	

    
	private var leftConstraint:NSLayoutConstraint! // дефолтная
	private var leftConstraint2:NSLayoutConstraint! // когда начали ввод текста
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundColor = .white

		// линия-сепаратор
		let sepLine = UIView()
		sepLine.backgroundColor = UIColor.lightGray
		sepLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 1)
		sepLine.translatesAutoresizingMaskIntoConstraints = false
		
		// кнопка "Отправить"
		sendButton.setImage(UIImage(named: "bttn_send"), for: .normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		
		
		addSubview(uploadImageView)
		addSubview(sepLine)
		addSubview(sendButton)
		addSubview(inputTextField)
		addSubview(insertGeo)
		
		NSLayoutConstraint.activate([
			// картинка слева (отправить фото)
			uploadImageView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: -5),
			uploadImageView.widthAnchor.constraint(equalToConstant: 44), // эпл рекомендует минимум 44
			uploadImageView.heightAnchor.constraint(equalToConstant: 44),
			
			insertGeo.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: -14),
			insertGeo.rightAnchor.constraint(equalTo: uploadImageView.leftAnchor, constant: 5),
			insertGeo.widthAnchor.constraint(equalToConstant: 34),
			insertGeo.heightAnchor.constraint(equalToConstant: 28),
			
			sepLine.topAnchor.constraint(equalTo: topAnchor),
			sepLine.leftAnchor.constraint(equalTo: leftAnchor),
			sepLine.rightAnchor.constraint(equalTo: rightAnchor),
			sepLine.heightAnchor.constraint(equalToConstant: 1),
			
			sendButton.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: -4),
			sendButton.rightAnchor.constraint(equalTo: rightAnchor),
			sendButton.widthAnchor.constraint(equalToConstant: 44),
			sendButton.heightAnchor.constraint(equalToConstant: 44),
			
			// текстовое поле
			inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 5),
			inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
			inputTextField.topAnchor.constraint(equalTo: topAnchor, constant: 7),
			
			inputTextField.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: -6)
		])
		inputTextField.contentInset.bottom = 20 // чтоб при скролле введенного текста его не закрывала клава снизу
		
		leftConstraint = uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 40)
		leftConstraint.isActive = true
		leftConstraint2 = uploadImageView.rightAnchor.constraint(equalTo: leftAnchor, constant: 0)
		leftConstraint2.isActive = false
	}
	
	
		
	
	private func switchConstraint(){
		
		if leftConstraint.isActive {
			leftConstraint.isActive = false
			leftConstraint2.isActive = true
		}
		else{
			leftConstraint2.isActive = false
			leftConstraint.isActive = true
		}
		UIView.animate(withDuration: 0.4) {
			self.layoutIfNeeded()
		}
	}
	
	
	
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
			switchConstraint()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.isScrollEnabled = false
            textView.text = dict[21]![0]
            textView.textColor = UIColor.lightGray
			switchConstraint()
        }
        else {
            textView.setContentOffset(.zero, animated: true)
            checkOnEmpty()
        }
    }
    

    
    
    
    public func textViewDidChange(_ textView: UITextView) {
        // отслеживаем "Enter" с клавиатуры
        if textView.text.last == "\n" {
            textView.text.removeLast()
            onSend()
            return
        }
        
        // textView самостоятельно увеличивает свой размер
        // по мере ввода текста
        
        if textView.frame.height >= 90 { // 90 - это 3 строки текста
            textView.isScrollEnabled = true
        }
        else{
            textView.isScrollEnabled = false
            // пересчитываем высоту self под новую высоту textView
            self.invalidateIntrinsicContentSize()
			textView.invalidateIntrinsicContentSize()
        }
        checkOnEmpty()
    }
    

//    override func layoutSubviews() {
//		super.layoutSubviews()
//		layoutIfNeeded()
//        self.reloadInputViews()
//		setNeedsUpdateConstraints() // проверить!
//    }
	

    
    /// пересчитываем собственный размер (высоту)
    override var intrinsicContentSize: CGSize {
        
        // высчитываем новый размер высоты
		let newSize = CGSize(width: inputTextField.bounds.width, height: .infinity)
        var estimatedSize = inputTextField.sizeThatFits(newSize)
		
        estimatedSize.height += 14
        return estimatedSize
    }
    
    
    
    @objc private func onSend(){
        if inputTextField.textColor == UIColor.lightGray{
            return
        }
        
        if !inputTextField.isFocused {
            inputTextField.setContentOffset(.zero, animated: false)// фикс - плейсхолдер не сползает вниз
        }
        
        chatController?.onSendClick() // здесь очищается текст
        self.invalidateIntrinsicContentSize()
        
        if !inputTextField.isFirstResponder { // если поле заполнено текстом но клава уже заехала
            inputTextField.isScrollEnabled = false
            inputTextField.text = dict[21]![0]
            inputTextField.textColor = UIColor.lightGray
			switchConstraint()
        }
        checkOnEmpty()
    }
        
    

    private func checkOnEmpty(){
        if inputTextField.text.isEmpty {
            sendButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        else {
            if inputTextField.textColor == UIColor.lightGray{
                sendButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
            else {
				// sendButton.tintColor = #colorLiteral(red: 0.1450980392, green: 0.5294117647, blue: 1, alpha: 1)
                sendButton.tintColor = UIConfig.mainThemeColor
            }
        }
    }
    
    
     
    
}














