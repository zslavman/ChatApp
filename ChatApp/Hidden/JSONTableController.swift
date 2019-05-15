//
//  JSONTable.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 30.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//
// если мы не на экране, когда это происходит (view.window == nil)
// tableView( _ : willDisplay:forRowAt:)


import UIKit
import MapKit


class PhotoData:Decodable {
	
	var index		:Int?
	var view		:String?
	var description	:String?
	var album_name	:String?
	var order		:Int?
	var isActive	:Bool?
	var city		:String?
	var geo			:[Geo]
	var reserv		:String?
}


struct Geo:Decodable {
	var latitude:Double?
	var longitude:Double?
}


class JSONTable: UITableViewController {
	
	private var dataForCells = [PhotoData]()
	private let cel_ID = "cell_ID"
	//private let json_link:String = "http://zslavman.zzz.com.ua/imgdb/index.json"
	// внутненняя ссылка на гуглдиск
	//private let json_link2:String = "https://drive.google.com/file/d/15vtUxi965XwNL7WAcUEgY0deGUpCkHFH/view?usp=sharing"
	// прямая ссылка на гуглдиск
	private let json_link2:String = "https://drive.google.com/uc?export=download&id=15vtUxi965XwNL7WAcUEgY0deGUpCkHFH"
	private let imgs_link:String = "http://zslavman.zzz.com.ua/imgdb/"
	private var tasks = Set<ImageLoader>() // таски на скачивание, которые будем отменять при выходе
	
	//https://drive.google.com/open?id=1Rbk49RDjWffwbs-nMA9WaMjsaOAKWg_r
	//https://drive.google.com/uc?export=download&id=1Rbk49RDjWffwbs-nMA9WaMjsaOAKWg_r
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(goBack))
		
		tableView.register(UINib(nibName: "cell_xib", bundle: nil), forCellReuseIdentifier: cel_ID)
		// чтоб не отображалась дефолтная таблица
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.backgroundColor = UIColor.white
		
		// уменьшаем отступы слева
		self.tableView.separatorInset.left = 8
		self.tableView.layoutMargins.left = 8
		
		
		title = "Threads test"
		
		downloadAndParseData()
	}
	

	
	
	// GCD
	private func downloadAndParseData(){
		
		SUtils.getJSON(link: json_link2) {
			(data:Data) in
			
			do {
				self.dataForCells = try JSONDecoder().decode([PhotoData].self, from: data)
				if !self.dataForCells.isEmpty {
					DispatchQueue.main.async(execute: {
						self.tableView.reloadData()
						SUtils.animateTableWithSections(tableView: self.tableView)
					})
				}
			}
			catch { print("Can't seriallize JSON!")	}
		}
	}
	
	

	@objc private func goBack(){
		
		for item in tasks {
			item.cancel() // относительное зевершение скачивания
		}
		tasks.removeAll()
		dismiss(animated: true, completion: nil)
	}
	
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataForCells.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cel_ID) as? WorkCell else { return UITableViewCell() }
		let currentCellData = dataForCells[indexPath.row]
		let fullLink = imgs_link + currentCellData.view!
		
		cell.label.text = currentCellData.description
		cell.imageURLString = fullLink
		
		let imageLoader = ImageLoader(imageURLString: fullLink) {
			(image) in
			DispatchQueue.main.async {
				cell.updateImageViewWithImage(image)
			}
		}
		tasks.insert(imageLoader)
		return cell
	}
	
	
	
	
	
//	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//		guard let cell = tableView.dequeueReusableCell(withIdentifier: cel_ID) as? WorkCell else { return }
//		let currentCellData = dataForCells[indexPath.row]
//		let fullLink = imgs_link + currentCellData.view!
//
//		let imageLoader = ImageLoader(imageURLString: fullLink) {
//			(image) in
//			DispatchQueue.main.async {
//				cell.updateImageViewWithImage(image)
//			}
//		}
//
//		tasks.insert(imageLoader)
//	}
	
	
	
	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cel_ID) as? WorkCell else { return }
		
		for loader in tasks.filter({ $0.imageURLString == cell.imageURLString }){
			loader.cancel()
			tasks.remove(loader)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 85
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	
	

	
	
	// ТЕСТ загружаем картинки по ссылкам из JSON
	func loadNext(){
		
		print("Threads = \(Thread.current)")
		
		var images = [UIImage]()
		let imageGroup = DispatchGroup()
		
		for item in dataForCells {
			
			let dispWoIt = DispatchWorkItem {
				let link = self.imgs_link + item.view!
				guard let url = URL(string: link) else { return }
				
				print("\(link)  Threads = \(Thread.current)")
				
				if let data = try? Data(contentsOf: url){
					images.append(UIImage(data: data)!)
					print("\(link) --- DONE!")
				}
			}
			//tasks.insert(dispWoIt)
			DispatchQueue.global(qos: .userInitiated).async(group: imageGroup, execute: dispWoIt)
		}
		
		imageGroup.notify(queue: DispatchQueue.main) {
			print("Все картинки скачаны")
		}
	}
	
	
}

























