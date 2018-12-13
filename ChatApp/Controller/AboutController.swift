//
//  AboutController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 13.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class AboutController: UIViewController {

	
	let backImage:UIImageView = {
		let bi = UIImageView()
		bi.image = UIImage(named: "screen")
		bi.contentMode = .scaleToFill
		bi.translatesAutoresizingMaskIntoConstraints = false
		return bi
	}()
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = dict[4]![LANG] // О приложении
		
//		tabBarController?.tabBarItem.
		
		
		print("frame_size = \(view.frame.size)")
		print("screen_size = \(UIScreen.main.bounds.size)")
		view.addSubview(backImage)
		
		NSLayoutConstraint.activate([
			backImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backImage.widthAnchor.constraint(equalTo: view.widthAnchor),
			backImage.heightAnchor.constraint(equalTo: view.heightAnchor),
	
			
		])
		
		
		
    }


	

}




















