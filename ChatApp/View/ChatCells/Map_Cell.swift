//
//  Map_Cell.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 01.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import MapKit


class Map_Cell: ChatMessageCell, MKMapViewDelegate {
	
	
	private let mapView: MKMapView = {
		let mapView = MKMapView()
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.showsCompass = false
		mapView.mapType = .standard
		if #available(iOS 11.0, *){
			mapView.showsScale = false
		}
		else {
			mapView.showsScale = true
		}
		mapView.isRotateEnabled = false
		mapView.isZoomEnabled = true
		mapView.isScrollEnabled = true
		mapView.showsBuildings = true
		mapView.isMultipleTouchEnabled = true
		mapView.isUserInteractionEnabled = true
		mapView.layer.cornerRadius = ChatMessageCell.cornRadius
		mapView.clipsToBounds = true
		mapView.showsPointsOfInterest = true

		return mapView
	}()



	func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
		print("Закончили ренедеринг карты")
	}
	
	
	//*************************
	//  К О Н С Т Р У К Т О Р *
	//*************************
	override init(frame: CGRect){
		super.init(frame: frame)
		
		mapView.delegate = self
		addSubview(mapView)
		
		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
			mapView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
			mapView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor)
		])
		
		// для 11 можно в карту встроить шкалу в желаемом месте
		if #available(iOS 11.0, *){
			// шкала масштаба
			let scaleView = MKScaleView(mapView: mapView)
			scaleView.translatesAutoresizingMaskIntoConstraints = false
			scaleView.scaleVisibility = .hidden
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























