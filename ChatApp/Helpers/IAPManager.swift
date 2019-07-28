//
//  IAPManager.swift
//  ChatApp
//
//  Created by Zinko Viacheslav on 28.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import StoreKit


struct IAPProducts {
	static let nonConsumable1 = "organic.ChatApp.FirstTestPurchase"
	static let nonConsumable2 = "organic.ChatApp.SecondTestPurchase"
}

class IAPManager: NSObject {
	public static let shared = IAPManager()
	public var receivedProducts = [SKProduct]()
	private let paymentQue = SKPaymentQueue.default()
	
	private override init() {
		
	}
	
	public func initPurchases(callback: @escaping (Bool) -> ()) {
		guard SKPaymentQueue.canMakePayments() else {
			callback(false)
			return
		}
		paymentQue.add(self)
		callback(true)
	}
	
	public func getProductsByIDs() {
		let identifiers: Set = [
			IAPProducts.nonConsumable1,
			IAPProducts.nonConsumable2,
		]
		let productRequest = SKProductsRequest(productIdentifiers: identifiers)
		productRequest.delegate = self
		productRequest.start() // will receive response in SKProductsRequestDelegate method
	}
	
	
	public func getLocalPriceForProduct(_ product: SKProduct) -> String {
		let numberformatter = NumberFormatter()
		numberformatter.numberStyle = .currency
		numberformatter.locale = product.priceLocale
		if let returned = numberformatter.string(from: product.price) {
			return returned
		}
		return "nil"
	}
	
	
	public func purchase(product: SKProduct) {
		let payment = SKPayment(product: product)
		paymentQue.add(payment) // will receive response in SKPaymentTransactionObserver protocol method
	}
	
}


extension IAPManager: SKPaymentTransactionObserver {
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .deferred: break // suspended state
			case .purchasing: break
			case .failed: print("purchase failed!")
			case .purchased: print ("succesfully purchased!")
			case .restored: print("restored")
			}
		}
	}
	
}

extension IAPManager: SKProductsRequestDelegate {
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		receivedProducts = response.products
		guard !receivedProducts.isEmpty else { return }
		NotificationCenter.default.post(name: .didReceiveProducts, object: receivedProducts)
	}
}

extension NSNotification.Name {
	public static let didReceiveProducts = Notification.Name("didReceiveProducts")
}
