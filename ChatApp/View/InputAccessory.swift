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
        }
    }
    
    public lazy var inputTextField: UITextView = {
        let tf = UITextView()
        tf.text = placeholderStr
        tf.textColor = UIColor.lightGray
        tf.backgroundColor = .clear
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.returnKeyType = .send // всего лишь вид кнопки "Enter"
        tf.delegate = self
        tf.isScrollEnabled = false
        return tf
    }()
    
    
    private let uploadImageView: UIImageView = {
        let uv = UIImageView()
        uv.image = UIImage(named: "upload_image_icon")
        uv.isUserInteractionEnabled = true
        uv.translatesAutoresizingMaskIntoConstraints = false
        return uv
    }()
    
    private var placeholderStr:String = "Введите сообщение..."
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    
    
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
		
		NSLayoutConstraint.activate([
			// картинка слева (отправить фото)
			uploadImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
			uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
			uploadImageView.widthAnchor.constraint(equalToConstant: 44), // эпл рекомендует минимум 44
			uploadImageView.heightAnchor.constraint(equalToConstant: 44),
			
			sepLine.topAnchor.constraint(equalTo: topAnchor),
			sepLine.leftAnchor.constraint(equalTo: leftAnchor),
			sepLine.rightAnchor.constraint(equalTo: rightAnchor),
			sepLine.heightAnchor.constraint(equalToConstant: 1),
			
			sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
			sendButton.rightAnchor.constraint(equalTo: rightAnchor),
			sendButton.widthAnchor.constraint(equalToConstant: 44),
			sendButton.heightAnchor.constraint(equalToConstant: 44),
			
			// текстовое поле
			inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 10),
			inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
			inputTextField.topAnchor.constraint(equalTo: topAnchor, constant: 7),
			inputTextField.heightAnchor.constraint(equalTo: heightAnchor)
		])
		inputTextField.contentInset.bottom = 20 // чтоб при скролле введенного текста его не закрывала клава снизу
	}
		
	
	
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.isScrollEnabled = false
            textView.text = placeholderStr
            textView.textColor = UIColor.lightGray
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
            inputTextField.text = placeholderStr
            inputTextField.textColor = UIColor.lightGray
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














