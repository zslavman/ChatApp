//
//  Map_Cell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 01.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import MapKit


class Map_Cell: ChatMessageCell {
	
	
	private lazy var mapView: MKMapView = {
		let map = MKMapView()
		map.translatesAutoresizingMaskIntoConstraints = false
		map.showsCompass = false
		if #available(iOS 11.0, *){
			map.showsScale = false
		}
		else {
			map.showsScale = true
		}
		map.isRotateEnabled = false
		map.isZoomEnabled = true
		map.isScrollEnabled = true
		map.showsBuildings = true
		map.isMultipleTouchEnabled = true
		map.isUserInteractionEnabled = true
		map.layer.cornerRadius = ChatMessageCell.cornRadius
		map.clipsToBounds = true
		return map
	}()
	
	
	
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override init(frame: CGRect){
		super.init(frame: frame)
		
		addSubview(mapView)
		
		NSLayoutConstraint.activate([
			// для геопозиции (если такоевое будет)
			mapView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
			mapView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
			mapView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
			mapView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)
		])
		
		
		// для 11 можно в карту встроить шкалу где хочется а не так как в 10
		if #available(iOS 11.0, *){
			// шкала масштаба
			let scaleView = MKScaleView(mapView: mapView)
			scaleView.translatesAutoresizingMaskIntoConstraints = false
			scaleView.scaleVisibility = .adaptive
			scaleView.isUserInteractionEnabled = false
			scaleView.legendAlignment = .trailing
			mapView.addSubview(scaleView)
			
			// let safeGuides:UILayoutGuide = self.mapView.safeAreaLayoutGuide
			
			NSLayoutConstraint.activate([
				scaleView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -10),
				scaleView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -13),
				scaleView.heightAnchor.constraint(equalToConstant: 30),
				scaleView.widthAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.5)
			])
			
			let compassButton = MKCompassButton(mapView: mapView)
			compassButton.frame.origin = CGPoint(x: 10, y: 10)
			compassButton.compassVisibility = .adaptive
			mapView.addSubview(compassButton)
			compassButton.alpha = 0.5
			
//			// Removeing compass
//			for view in mapView.subviews {
//				if view.isKind(of: NSClassFromString("MKCompassView")!) {
//					view.removeFromSuperview()
//				}
//			}
		}
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	/// вызывается только из ChatLogController
	override func setupCell(linkToParent: ChatLogController, message: Message, indexPath: IndexPath) {
		super.setupCell(linkToParent: linkToParent, message: message, indexPath: indexPath)
	
		bubbleView.backgroundColor = .clear
		textView.isHidden = true
		
		bubbleWidthAnchor?.constant = UIScreen.main.bounds.width * 3/4
		mapCenterAndAddPin()
		mapView.isHidden = false
		
	}
		
	
	
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		mapView.isHidden = true
	}
	
	
	
	
	
	
	
	
	private func mapCenterAndAddPin(){
		
		guard let message = message else { return }
		
		// центрируем карту на заданой точке
		let coord2D = CLLocationCoordinate2D(latitude: message.geo_lat!.doubleValue, longitude: message.geo_lon!.doubleValue)
		let viewRegion = MKCoordinateRegionMakeWithDistance(coord2D, ChatLogController.prefferedMapScale, ChatLogController.prefferedMapScale)
		mapView.setRegion(viewRegion, animated: false)
		
		let annotation = MKPointAnnotation()
		annotation.coordinate = coord2D
		mapView.addAnnotation(annotation)
	}
	
	
	
	
	
	
	
	
	
}























