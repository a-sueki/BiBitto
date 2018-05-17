//
//  AppDelegate.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import GoogleMobileAds
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PurchaseManagerDelegate {

    var window: UIWindow?
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
        GADMobileAds.configure(withApplicationID: "ca-app-pub-5249520015075390~7571515919")
        
        // 初回起動チェック用
        UserDefaults.standard.register(defaults: ["firstLaunch":true])
        
        // 初期表示
        if let tabvc = self.window!.rootViewController as? UITabBarController  {
            tabvc.selectedIndex = 1 // 0 が一番左のタブ
        }
        
        // ナビゲーションバーのフォントを変更
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):UIFont(name: "Gill Sans", size: 20)!]
        } else {
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):UIFont(name: "Gill Sans", size: 20)!]
        }
        
        
        // Register APNs
        if #available(iOS 10.0, *) {
            
             UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: { (granted, error) in
                if error != nil {
                    return
                }
                if granted {
                    print("通知許可")
                    UNUserNotificationCenter.current().delegate = self
                } else {
                    print("通知拒否")
                }
            })
        } else {
            // iOS 9以下
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        //バッジの数を０にする.
        UIApplication.shared.applicationIconBadgeNumber = 0

        // デリゲート設定
        PurchaseManager.shared.delegate = self
        // オブザーバー登録
        SKPaymentQueue.default().add(PurchaseManager.shared)
        
        return true
    }
    
    // 課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("#### didFinishUntreatedPurchaseWithTransaction ####")
        // TODO: コンテンツ解放処理
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
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
        // オブザーバー登録解除
        SKPaymentQueue.default().remove(PurchaseManager.shared)
    }
    // バックグラウンドで来た通知をタップしてアプリ起動したら呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.didReceive start")
        
        //バッジの数を０にする.
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.didReceive end")
    }
    // アプリがフォアグラウンドの時に通知が来たら呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.willPresent start")
        
        completionHandler([.alert, .badge, .sound])
        
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.willPresent end")
    }
    
}

