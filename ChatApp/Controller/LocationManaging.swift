//
//  LocationManaging.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import CoreLocation


extension ChatController:CLLocationManagerDelegate {
	
	
	
	
	internal func setupGeo(){
		
		locationManager = CLLocationManager()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.delegate = self
	}
	
	
	
	
	
	// при нажатии на "Поделиться координатами"
	@objc internal func checkLocationAuthorization() {
		
		switch CLLocationManager.authorizationStatus() {
			
		case .authorizedWhenInUse, .notDetermined:
			locationManager.requestWhenInUseAuthorization()
			if CLLocationManager.locationServicesEnabled(){
				myCurrentPlace = nil
				if #available(iOS 11.0, *){
//					locationManager.requestLocation()
					print("Отправили запрос на получение коориднат...")
					locationManager.startUpdatingLocation()
				}
				else{
					getLocation()
				}
			}
		case .denied, .restricted:
			showAlert()
		case .authorizedAlways:
			break
		}
	}
	

	
	
	/// получение координат (iOS 11.0+) в 10-ке это тоже работает но с огромной задержкой около 10с
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if self.myCurrentPlace != nil{ // на 10.3.3 баг - этот метод срабатывает дважды!ы
			manager.stopUpdatingLocation()
			return
		}
		
		let myCurrentPlace = locations.last!
		self.myCurrentPlace = myCurrentPlace
		let lat = myCurrentPlace.coordinate.latitude
		let lon = myCurrentPlace.coordinate.longitude
		
		print("latitude = \(lat)   longitude = \(lon)")

		sendMessageWithGeo(lat: lat, lon: lon)
		
		let geocoder = CLGeocoder()
		geocoder.reverseGeocodeLocation(myCurrentPlace) {
			(placemarks, error) in
			
			if (error != nil){
				print("error in reverseGeocode")
				return
			}
			
			if let placemarks = placemarks, placemarks.count > 0 {
				let place = placemarks.first!
				print(place.locality ?? "nil") 				// Київ
				print(place.administrativeArea ?? "nil") 	// Киев
				print(place.country ?? "nil")				// Украина
			}
		}
	}
	
	
	/// получение координат (iOS 10)
	private func getLocation(){
		if let myCurrentPlace = locationManager.location?.coordinate{
			
			let lat = myCurrentPlace.latitude
			let lon = myCurrentPlace.longitude
			print("latitude = \(lat)   longitude = \(lon)")
			
			sendMessageWithGeo(lat: lat, lon: lon)
		}
	}
	
	
	
	
	
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error = \(error.localizedDescription)")
	}
	

	
	/// показываем пояснение, что нужно разрешить использование геолокации в настройках
	private func showAlert(){
		let message = dict[36]![LANG] // "Для использования этой функции необходимо разрешить использование геолокации в настройках"
		let alertController = Calculations.alert(message: message, title: dict[37]![LANG], OK_action: nil) // "Включите геолокацию"
		present(alertController, animated: true, completion: nil)
	}
	
	
	
	
	
	/// отправка сообщения с геолокацией
	private func sendMessageWithGeo(lat:Double, lon:Double){
		
		let properties:[String:Any] = [
			"geo_lat"	:lat,
			"geo_lon"	:lon
		]
		sendMessage_with_Properties(properties: properties)
	}
	
	
	
	
	
	
	
	
}



























