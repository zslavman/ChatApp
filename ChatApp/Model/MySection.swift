//
//  MySection.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 08.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import NPTableAnimator


public struct MySection: TableAnimatorSection {
	
	//	let id: Int
	
	public var cells: [Message]
	
	public var updateField: Int {
		return 0
	}
	
	subscript(value: Int) -> Message {
		return cells[value]
	}
	
	
	public static func == (lhs: MySection, rhs: MySection) -> Bool {
		// return lhs.id == rhs.id // когда секций больше 1
		return true
	}
	
}
