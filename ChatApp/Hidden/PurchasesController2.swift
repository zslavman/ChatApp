//
//  PurchasesController2.swift
//  ChatApp
//
//  Created by Zinko Viacheslav on 28.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import SwiftyStoreKit

class PurchasesController2: UIViewController {
	
	private var tableView: UITableView!
	private let cellID = "id"
	private var purchases = [SKProduct]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationItem.title = "Purchases"
		installTable()
		getAvailablePurchases()
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
	
	
	private func getAvailablePurchases() {
		let purchaseIDs = Set(IAPProducts.allCases.compactMap{$0.rawValue})
		
		SwiftyStoreKit.retrieveProductsInfo(purchaseIDs) {
			result in
			if let error = result.error {
				print("Error: \(error.localizedDescription)")
				return
			}
			if !result.invalidProductIDs.isEmpty {
				print("Invalid products: \(result.invalidProductIDs)")
			}
			for product in result.retrievedProducts {
				self.purchases.append(product)
			}
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	
	@objc private func onRestoreClick() {
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
}




extension PurchasesController2: UITableViewDelegate, UITableViewDataSource {
	
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
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		let content = purchases[indexPath.row]
		let str = content.localizedTitle + " - " + content.localizedPrice!
		cell.textLabel?.text = str
		return cell
	}
	
}

