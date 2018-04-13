//
//  NotificationViewController.swift
//  BiBitto
//
//  Created by admin on 2018/04/12.
//  Copyright © 2018年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import SVProgressHUD
import UserNotifications
import CoreLocation

class NotificationViewController: FormViewController {

    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: NotificationViewController viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: NotificationViewController viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeForm(){
        print("DEBUG_PRINT: NotificationViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section("通知")
            <<< SwitchRow("TimeNotification") {
                $0.title = "時刻で通知する"
                if UserDefaults.standard.object(forKey: DefaultString.NoticeFlag) != nil {
                    $0.value = UserDefaults.standard.bool(forKey: DefaultString.NoticeFlag)
                }else{
                    $0.value = true
                }
            }
            <<< TimeInlineRow("Time") {
                $0.hidden = .function(["TimeNotification"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "TimeNotification")
                    return row.value ?? false == false
                })
                $0.title = "通知時刻"
                $0.value = Date().addingTimeInterval(60*60*24)
            }
            <<< PushRow<RepeatInterval>("Repeat") {
                $0.hidden = .function(["TimeNotification"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "TimeNotification")
                    return row.value ?? false == false
                })
                $0.title = "繰り返し"
                $0.options = RepeatInterval.allValues
                $0.value = .Every_Day
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "通知設定を保存する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: SettingViewController.save \(error)のため処理は行いません")
                    }else{
                        self?.save()
                    }
            }
            
            +++ Section("通知（場所）")
            <<< SwitchRow("LocationNotification") {
                $0.title = "場所で通知する"
                if UserDefaults.standard.object(forKey: DefaultString.NoticeFlag) != nil {
                    $0.value = UserDefaults.standard.bool(forKey: DefaultString.NoticeFlag)
                }else{
                    $0.value = true
                }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "通知設定を保存する（場所）"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: SettingViewController.save \(error)のため処理は行いません")
                    }else{
                        self?.saveLocation()
                    }
            }

        print("DEBUG_PRINT: SettingViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    enum RepeatInterval : String, CustomStringConvertible {
        case Never = "なし"
        case Every_Day = "あり"
        
        var description : String { return rawValue }
        
        static let allValues = [Never, Every_Day]
    }
    
    @IBAction func save() {
        print("DEBUG_PRINT: SettingViewController save start")
        
        for (key,value) in form.values() {
            if value != nil {
                inputData["\(key)"] = value
            }
        }
        registerTimeLocalNotification(inputData: inputData)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        
        print("DEBUG_PRINT: SettingViewController save end")
    }
    
    func registerTimeLocalNotification(inputData: [String : Any]) {
        print("DEBUG_PRINT: SettingViewController registerLocalNotification start")
        
        //　通知設定に必要なクラスをインスタンス化
        let trigger: UNNotificationTrigger
        let content = UNMutableNotificationContent()
        
        // 通知条件をインスタンス化
        let inputTime = inputData["Time"] as! Date
        let inputRepeat = inputData["Repeat"] as! RepeatInterval
        
        // システムのカレンダーを取得
        let cal = Calendar.current
        var dataComps = cal.dateComponents([.hour, .minute], from: inputTime)
        
        // トリガー設定
        if inputRepeat == RepeatInterval.Every_Day {
            trigger = UNCalendarNotificationTrigger(dateMatching: dataComps, repeats: true)
        }else{
            trigger = UNCalendarNotificationTrigger(dateMatching: dataComps, repeats: false)
        }
        
        // 通知内容の設定
        content.title = "ビビッとくる！俺の名言コレクション"
        content.body = "今日のビビッとくる言葉は？"
        content.sound = UNNotificationSound.default()
        content.badge = 0
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "BiBittoNotification", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        print("DEBUG_PRINT: SettingViewController registerLocalNotification end")
    }
    
    @IBAction func saveLocation() {
        print("DEBUG_PRINT: SettingViewController saveLocation start")
        
        for (key,value) in form.values() {
            if value != nil {
                inputData["\(key)"] = value
            }
        }
        registerLocationLocalNotification(inputData: inputData)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        
        print("DEBUG_PRINT: SettingViewController saveLocation end")
    }
    
    func registerLocationLocalNotification(inputData: [String : Any]) {
        print("DEBUG_PRINT: SettingViewController registerLocationLocalNotification start")
        
        let center = CLLocationCoordinate2D(latitude: 37.335400, longitude: -122.009201)
        let region = CLCircularRegion(center: center, radius: 2000.0, identifier: "Headquarters")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        print("DEBUG_PRINT: SettingViewController registerLocationLocalNotification end")
    }
}
