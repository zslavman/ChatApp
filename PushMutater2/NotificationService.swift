//
//  NotificationService.swift
//  PushMutater2
//
//  Created by Zinko Viacheslav on 17.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
	private var trigger = false
	

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        let curTime = PushStaticMethods.stringTime()
        if let bestAttemptContent = bestAttemptContent {
            // modification content place
			if trigger {
				bestAttemptContent.title = "\(bestAttemptContent.title) (\(curTime)):"
			}
			else {
				bestAttemptContent.title = "\(bestAttemptContent.title):"
			}
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
