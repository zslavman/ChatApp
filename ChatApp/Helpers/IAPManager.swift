//
//  IAPManager.swift
//  ChatApp
//
//  Created by Zinko Viacheslav on 28.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import StoreKit


// this enum need to be received from third party server!
enum IAPProducts: String {
	case nonConsumable1 = "organic.ChatApp.FirstTestPurchase"
	case nonConsumable2 = "organic.ChatApp.SecondTestPurchase"
	case autoRenewable = "organic.ChatApp.Renewable"
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
			IAPProducts.nonConsumable1.rawValue,
			IAPProducts.nonConsumable2.rawValue,
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
			case .failed:
				transactionDidFail(transaction: transaction)
			case .purchased:
				transactionDidComplete(transaction: transaction)
			case .restored:
				transactionDidRestore(transaction: transaction)
			}
		}
	}
	
	
	private func transactionDidFail(transaction: SKPaymentTransaction) {
		guard let transactionError = transaction.error as NSError? else { return }
		if transactionError.code != SKError.paymentCancelled.rawValue {
			print("Transaction error: \(transaction.error!.localizedDescription)")
		}
		paymentQue.finishTransaction(transaction)
	}
	
	
	private func transactionDidComplete(transaction: SKPaymentTransaction) {
		let receiptValidator = ReceiptValidator()
		let result = receiptValidator.validateReceipt()
		
		switch result {
		case .error(let error):
			print(error.localizedDescription)
		case .success(let receipt):
			let productID = transaction.payment.productIdentifier
			// if it's non autorenewable
			guard let purchase = receipt.inAppPurchaseReceipts?.filter({$0.productIdentifier == IAPProducts.autoRenewable.rawValue}).first
				else {
				NotificationCenter.default.post(name: .didPurchaseCompleted, object: productID)
				paymentQue.finishTransaction(transaction)
				return
			}
			// For autorenewable purchases (subscriptions)
			// if subscription doesn't expired
			if purchase.subscriptionExpirationDate?.compare(Date()) == .orderedDescending {
				UserDefaults.standard.set(true, forKey: IAPProducts.autoRenewable.rawValue)
			}
			else {
				print("Subscription has ended")
				UserDefaults.standard.set(false, forKey: IAPProducts.autoRenewable.rawValue)
			}
			NotificationCenter.default.post(name: .didPurchaseCompleted, object: productID)
		}
		paymentQue.finishTransaction(transaction)
	}
	
	
	private func transactionDidRestore(transaction: SKPaymentTransaction) {
		paymentQue.finishTransaction(transaction)
	}
	
	
	public func restoreCompletedTransaction() {
		paymentQue.restoreCompletedTransactions()
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
	public static let didPurchaseCompleted = Notification.Name("didPurchaseCompleted")
}
