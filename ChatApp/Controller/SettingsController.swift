//
//  SettingsController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 10.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

	
	public var test = 125
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
		title = "Настройки"
		
		navigationController?.view.backgroundColor = UIConfig.mainThemeColor
    }




}
