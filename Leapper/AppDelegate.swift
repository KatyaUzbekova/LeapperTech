//
//  AppDelegate.swift
//  Leapper
//
//  Created by Kratos on 1/19/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import IQKeyboardManager
import UserNotifications
import Contacts
import Firebase
import CoreData
import SwiftKeychainWrapper
import SocketIO
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, MessagingDelegate  {
    static var fcmTokenUser = ""
    
    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?
    var navigator = Navigator()
    
    let manager = SocketManager(socketURL: URL(string: "http://3.20.197.77:8083")!, config: [.log(false), .compress])
    static var socket: SocketIOClient!
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {return false}
        guard navigator.getDestination(for: url) != nil else {
            return false
        }
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any?]) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let _ =           userActivity.webpageURL else { return false }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        AppDelegate.socket = manager.defaultSocket
        
        AppDelegate.socket.on(clientEvent: .connect) {data, ack in
            //  AppDelegate.socket.emit("echo", "haaa")
        }
        //        AppDelegate.socket.on("echo") { data,_ in
        //        }
        AppDelegate.socket.on("error") {data, ack in
            print("SOCKER ERROR \(data)")
        }
        Messaging.messaging().delegate = self
        let notificationCenter = UNUserNotificationCenter.current()
        
        // MARK:  -Remove Firebase Verification for Testing
        // Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        if #available(iOS 10.0, *) {
            notificationCenter.delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            notificationCenter.requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        return true }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is QrReaderController {
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "LeapperDialog")
            {
                tabBarController.present(newVC, animated: true)
                return false
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if SessionManager.shared.isLoggedIn() {
            AppDelegate.socket.disconnect()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if SessionManager.shared.isLoggedIn() {
            AppDelegate.socket.connect()
            SessionManager.shared.notificationCountStart()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
        if SessionManager.shared.isLoggedIn() {
            AppDelegate.socket.disconnect()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
        if userInfo[gcmMessageIDKey] != nil {
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        
        if userInfo[gcmMessageIDKey] != nil {
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
    }
    // MARK: Custom functions
    var contactStore = CNContactStore()
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func showMessage(_ message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("Birthdays", comment: "Ok"), message: message, preferredStyle: UIAlertController.Style.alert)
        
        let dismissAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertAction.Style.default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        
        presentedViewController.present(alertController, animated: true, completion: nil)
    }
    
    func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = NSLocalizedString("Toast.Message.AllowAccessToContacts", comment: "Allow access to contacts")
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    private func application(application: UIApplication,
                             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?){
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        AppDelegate.fcmTokenUser = fcmToken ?? ""
//        if AppDelegate.fcmTokenUser.count > 1 && KeychainWrapper.standard.string(forKey: "accessToken") != nil {
//            postToRegister(deviceToken: UIDevice.current.identifierForVendor!.uuidString, registrationToken: AppDelegate.fcmTokenUser)
//        }
        
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
        }
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if userInfo[gcmMessageIDKey] != nil {
            if let roomId = userInfo["room"]{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeController = storyboard.instantiateViewController(withIdentifier: "Messenger") as! ParticularChatViewController
                homeController.chatRoomId = ("\(roomId)")
                appDelegate.window?.rootViewController?.present(homeController, animated: false, completion: nil)
            }
        }
        else {
            NotificationCenter.default.post(name: NSNotification.Name("ReloadFeed"), object: nil, userInfo: nil)
        }
        completionHandler()
    }
}
