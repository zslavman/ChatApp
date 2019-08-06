//
//  PurchasesController.swift
//  ChatApp
//
//  Created by Zinko Viacheslav on 28.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class PurchasesController: UIViewController {
	
	private var tableView: UITableView!
	private let cellID = "id"
	private var purchases: [SKProduct] = IAPManager.shared.receivedProducts {
		didSet {
			tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveProducts(notif:)),
											   name: .didReceiveProducts, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didPurchaseCompleted(notif:)),
											   name: .didPurchaseCompleted, object: nil)
		view.backgroundColor = .white
		navigationItem.title = "Purchases"
		installTable()
		
//		navigationController?.navigationBar.prefersLargeTitles = true
//		navigationController?.navigationBar.largeTitleTextAttributes = [
//			.foregroundColor:  	UIColor.white,
//			.font:  			UIFont.boldSystemFont(ofSize: 30)]
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self,
															action: #selector(onRestoreClick))
	}
	
	
	private func installTable() {
		tableView = UITableView(frame: .zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
		tableView.tableFooterView = UIView()
		tableView.contentInset.top = 20
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
		])
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		navigationController?.navigationBar.prefersLargeTitles = false
	}
	
	
	@objc private func didReceiveProducts(notif: Notification) {
		guard let products = notif.object as? [SKProduct] else { return }
		self.purchases = products
	}
	
	@objc private func didPurchaseCompleted(notif: Notification) {
		guard let puchaseKind = notif.object as? String else { return }
		switch puchaseKind {
		case IAPProducts.nonConsumable1.rawValue:
			print("You got a \(puchaseKind)")
		case IAPProducts.nonConsumable2.rawValue:
			print("You got a \(puchaseKind)")
		case IAPProducts.autoRenewable.rawValue:
			if UserDefaults.standard.bool(forKey: IAPProducts.autoRenewable.rawValue) {
				print("Subscription enabled")
			}
			else {
				print("Subscription disabled")
			}
		default:
			print("Error: wrong product identifier!")
		}
	}
	
	
	@objc private func onRestoreClick() {
		IAPManager.shared.restoreCompletedTransaction()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
}

extension PurchasesController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return purchases.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		IAPManager.shared.purchase(product: purchases[indexPath.row])
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		let content = purchases[indexPath.row]
		let str = content.localizedTitle + " - " + IAPManager.shared.getLocalPriceForProduct(content)
		cell.textLabel?.text = str
		return cell
	}
	
}

