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
enum IAPProducts: String, CaseIterable {
	case nonConsumable1 = "organic.ChatApp.FirstTestPurchase"
	case nonConsumable2 = "organic.ChatApp.SecondTestPurchase"
	case autoRenewable = "organic.ChatApp.Renewable"
	case laja = "organic.ChatApp.Laja"
	
	// call "IAPProducts.allCases" to get an array of all cases
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
			case .purchasing:
				print("Purchasing")
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
				if !transaction.downloads.isEmpty {
					paymentQue.start(transaction.downloads)
				}
				else {
					paymentQue.finishTransaction(transaction)
				}
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
		print("Restoring purchases has started!")
		if !transaction.downloads.isEmpty {
			paymentQue.start(transaction.downloads)
		}
		else {
			paymentQue.finishTransaction(transaction)
		}
	}
	
	
	// user clicked "Restore" button
	public func restoreCompletedTransaction() {
		paymentQue.restoreCompletedTransactions()
	}
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		print("You successfully restored purchases!")
	}
	
	
	//MARK:- Hosted purchases (downloads)
	
	// will fire after paymentQue.start(transaction.downloads)
	func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
		for item in downloads {
			let download = item.downloadState
			switch download {
			case .waiting:
				NotificationCenter.default.post(name: .downloadWaiting, object: download)
			case .active:
				NotificationCenter.default.post(name: .downloadActive, object: download)
			case .finished:
				//moveDownloadedFiles(download) // move downloades files from Caches directory to Documents dir
				NotificationCenter.default.post(name: .downloadFinished, object: download)
				paymentQue.finishTransaction(item.transaction)
			case .failed:
				NotificationCenter.default.post(name: .downloadFailed, object: download)
				paymentQue.finishTransaction(item.transaction)
			case .cancelled:
				NotificationCenter.default.post(name: .downloadCancelled, object: download)
				paymentQue.finishTransaction(item.transaction)
			case .paused:
				NotificationCenter.default.post(name: .downloadPaused, object: download)
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
	public static let didPurchaseCompleted = Notification.Name("didPurchaseCompleted")
	public static let downloadWaiting 	= Notification.Name("download_Waiting")
	public static let downloadActive 	= Notification.Name("download_Active")
	public static let downloadFinished 	= Notification.Name("download_Finished")
	public static let downloadFailed 	= Notification.Name("download_Failed")
	public static let downloadCancelled = Notification.Name("download_Cancelled")
	public static let downloadPaused 	= Notification.Name("download_Paused")
}
