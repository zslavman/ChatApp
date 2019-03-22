//
//  UserDefFlags.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 13.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import Foundation


struct UserDefFlags {
	
	private enum keys: String {
		case sound_mess = "sound_mess"
		case vibro_mess = "vibro_mess"
		case limit_mess = "limit_mess"
		case lang 		= "lang"
	}
	
	static var sound_mess: Bool! {
		didSet{
			save(value: sound_mess, key: .sound_mess)
		}
	}
	static var vibro_mess: Bool! {
		didSet{
			save(value: vibro_mess, key: .vibro_mess)
		}
	}
	static var limit_mess: UInt! {
		didSet{
			save(value: limit_mess, key: .limit_mess)
		}
	}
	static var lang: UInt! {
		didSet{
			save(value: lang, key: .lang)
			LANG = Int(lang)
		}
	}
	
	
	
	init() {
		let s_flag = UserDefaults.standard.object(forKey: keys.sound_mess.rawValue)
		UserDefFlags.sound_mess = (s_flag == nil) ? true : s_flag as! Bool
		
		let v_flag = UserDefaults.standard.object(forKey: keys.vibro_mess.rawValue)
		UserDefFlags.vibro_mess = (v_flag == nil) ? false : v_flag as! Bool
		
		let lim_flag = UserDefaults.standard.object(forKey: keys.limit_mess.rawValue)
		UserDefFlags.limit_mess = (lim_flag == nil) ? 25 : lim_flag as! UInt
		
		let lang_flag = UserDefaults.standard.object(forKey: keys.lang.rawValue)
		UserDefFlags.lang = (lang_flag == nil) ? 0 : lang_flag as! UInt
		if lang_flag == nil{
			if Locale.current.languageCode == "ru"{
				UserDefFlags.lang = 0
			}
			else {
				UserDefFlags.lang = 1
			}
		}
		else {
			UserDefFlags.lang = (lang_flag as! UInt)
		}
	}
	
	
	
	
	
	
	private static func save(value: Any, key: keys){
		//		print("key = \(key.rawValue) ---> value = \(value)")
		UserDefaults.standard.set(value, forKey: key.rawValue)
		UserDefaults.standard.synchronize()
	}
}










