//
//  ScriptMessageHandler.swift
//

import WebKit

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {

    var logging = Bool()
    var viewController: ViewController!

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "windowOpen" {
            windowOpen(message);
        } else if message.name == "windowColorSchemeChange" {
            windowColorSchemeChange(message)
        } else if message.name == "fetch" {
            fetch(message)
        } else {
            NSLog("unknown message: \(message)")
        }
    }

    func windowOpen(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let url = messageBody["0"] as? String {
                NSLog("windowOpen \(url)")
                NSWorkspace.shared.open(URL.init(string: url)!)
            }
        }
    }

    func windowColorSchemeChange(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let darkMode = messageBody["darkMode"] as? Int {
                if darkMode == 1 {
                    viewController.updateTitleBar(.dark)
                } else {
                    viewController.updateTitleBar(.light)
                }
            }
        }
    }

    func handleFetchListNotifications(_ doc : NSDictionary) {
        var unreadCount = 0;
        if let notificationsList = doc["notifications"] as? [NSDictionary],
            let cursor = doc["cursor"] as? String
        {
            for notification in notificationsList {
                if let isRead = notification["isRead"] as? Int {
                    if isRead == 0 {
                        unreadCount += 1
                    }
                }
            }
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.updateNotifCount(cursor: cursor, count: unreadCount)
        }
    }

    func fetch(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let urlString = messageBody["url"] as? String,
               let response = messageBody["response"] as? NSDictionary
            {
                if urlString.contains("listNotifications") {
                    handleFetchListNotifications(response)
                }
            }
        }
    }

}
