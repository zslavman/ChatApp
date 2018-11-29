//
//  LocationManaging.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 29.11.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import CoreLocation


extension ChatLogController:CLLocationManagerDelegate {
	
	
	
	
	internal func setupGeo(){
		
		locationManager = CLLocationManager()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.delegate = self
	}
	
	
	
	
	
	// при нажатии на "Поделиться координатами"
	internal func checkLocationAuthorization() {
		
		switch CLLocationManager.authorizationStatus() {
			
		case .authorizedWhenInUse, .notDetermined:
			locationManager.requestWhenInUseAuthorization()
			if CLLocationManager.locationServicesEnabled(){
				myCurrentPlace = nil
				locationManager.requestLocation()
			}
		case .denied, .restricted:
			showAlert()
		case .authorizedAlways:
			break
		}
	}
	

	
	
	/// получение координат
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if self.myCurrentPlace != nil{ // на 10.3.3 баг - этот метод срабатывает дважды!ы
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
	
	
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error = \(error.localizedDescription)")
	}
	

	
	/// показываем пояснение, что нужно разрешить использование геоположения в настройках
	private func showAlert(){
		let message = "Для использования этой функции необходимо разрешить использование геопозиции в настройках"
		let alertController = UIAlertController(title: "Включите геопозицию", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "Ок", style: .default, handler: nil)
		alertController.addAction(ok)
		
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



























