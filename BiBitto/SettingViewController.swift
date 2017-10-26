//
//  SettingViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import UserNotifications

class SettingViewController: FormViewController {
    
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: SettingViewController.viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: SettingViewController.viewDidLoad end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initializeForm(){
        print("DEBUG_PRINT: SettingViewController.initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section("通知設定")
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
            
            +++ Section("アカウント")
            <<< EmailRow("mail") {
                $0.placeholder = "Email"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Mail)
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnBlur
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = validationMsg
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            <<< PasswordRow("password") {
                $0.placeholder = "Password"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Password)
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 6, msg: ErrorMsgString.RulePassword))
                $0.add(rule: RuleMaxLength(maxLength: 12, msg: ErrorMsgString.RulePassword))
                $0.validationOptions = .validatesOnBlur
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = validationMsg
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }


            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "保存"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: SettingViewController.save \(error)のため処理は行いません")
                    }else{
                        self?.save()
                    }
        }
        print("DEBUG_PRINT: SettingViewController.initializeForm end")
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
        print("DEBUG_PRINT: SettingViewController.save start")
        
        for (key,value) in form.values() {
            if value != nil {
                inputData["\(key)"] = value
            }
        }
        registerLocalNotification(inputData: inputData)
        
        // UserDefaultsを更新
        // UserDefaults.standard.set(false, forKey: DefaultString.GuestFlag)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        print("DEBUG_PRINT: SettingViewController.save end")
    }
    
    func registerLocalNotification(inputData: [String : Any]) {
        print("DEBUG_PRINT: SettingViewController.registerLocalNotification start")

        //　通知設定に必要なクラスをインスタンス化
        let trigger: UNNotificationTrigger
        let content = UNMutableNotificationContent()

        // 通知条件をインスタンス化
        let inputTime = inputData["Time"] as! Date
        let inputRepeat = inputData["Repeat"] as! RepeatInterval
        print(inputTime) //2017-10-25 03:04:13 +0000

        // システムのカレンダーを取得
        let cal = Calendar.current
        var dataComps = cal.dateComponents([.hour, .minute], from: inputTime)
        print("\(dataComps.hour!)時\(dataComps.minute!)分") //

        // トリガー設定
        if inputRepeat == RepeatInterval.Every_Day {
            trigger = UNCalendarNotificationTrigger(dateMatching: dataComps, repeats: true)
        }else{
            trigger = UNCalendarNotificationTrigger(dateMatching: dataComps, repeats: false)
        }

        // 通知内容の設定
        content.title = "ビビッとくる！俺の名言コレクション"
        content.body = "今日のビビッとフレーズは？"
        content.sound = UNNotificationSound.default()
        content.badge = 0
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "BiBittoNotification", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        print("DEBUG_PRINT: SettingViewController.registerLocalNotification end")
    }
}

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}
