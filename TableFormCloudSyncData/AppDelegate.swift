//
//  AppDelegate.swift
//  TableFormCloudSyncData
//
//  Created by Sebastiao Gazolla Costa Junior on 14/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let coreDataManager:CoreDataManager = CoreDataManager.init(modelName: "TableFormCoreData")

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent: UNNotification,
                                withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        print("userNotificationCenter WillPresent")
        withCompletionHandler([.alert, .sound, .badge])
    }
    
    fileprivate func requestNotificationAuthorization(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            }
            if granted{
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    print("application registerForRemoteNotifications")
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let main = EmployeesController()
        main.context = coreDataManager.mainManagedObjectContext
        let nav = UINavigationController(rootViewController: main)
        self.window!.rootViewController = nav
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let employee = CKEmployee()
        employee.iCloudSubscribe()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let userInfo = userInfo as? [String: NSObject] {
            
            let notification: CKNotification = CKNotification(fromRemoteNotificationDictionary: userInfo)
            
            if (notification.notificationType == CKNotificationType.query) {
                let queryNotification = notification as! CKQueryNotification
                let recordID = queryNotification.recordID!
                if queryNotification.queryNotificationReason == .recordDeleted {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeleteEmployee"), object: recordID)
                } else {
                    CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddEmployee"), object: record)
                    }
                }
            }
        }
        
        completionHandler(.newData)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

