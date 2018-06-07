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
    var selectedLocationName: String?
    var selectedLatitude: String?
    var selectedLongitude: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: NotificationViewController viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))

        print("DEBUG_PRINT: NotificationViewController viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: NotificationViewController viewWillAppear start")
        
        // 選択済みの座標を取得
        self.selectedLatitude = UserDefaults.standard.string(forKey: DefaultString.SelectedLatitude)
        self.selectedLongitude = UserDefaults.standard.string(forKey: DefaultString.SelectedLongitude)
        
        // 選択済みの地名を取得
        if self.selectedLatitude == nil {
            self.selectedLocationName = "指定してください"
        }else if let locationName = UserDefaults.standard.string(forKey: DefaultString.SelectedLocation) , locationName != "" {
            self.selectedLocationName =  locationName
        }else{
            self.selectedLocationName = "ピン留めした場所"
        }

        let locationSection: Section = form.allSections[1]
        locationSection.reload()
        
        print("DEBUG_PRINT: NotificationViewController viewWillAppear end")
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
            Section("時刻")
            <<< SwitchRow("TimeNotification") {
                $0.title = "指定時刻で通知"
                if UserDefaults.standard.object(forKey: DefaultString.NoticeTimeFlag) != nil {
                    $0.value = UserDefaults.standard.bool(forKey: DefaultString.NoticeTimeFlag)
                }else{
                    $0.value = false
                }
                }.onChange { row in
                    if row.value! == false {
                        // 通知OFF
                        let identifiers = ["BiBittoTimeNotification"]
                        UNUserNotificationCenter.current().removeNotificationsCompletely(withIdentifiers: identifiers)
                        UserDefaults.standard.set(false ,forKey: DefaultString.NoticeTimeFlag)
                     }
            }
            
            <<< TimeInlineRow("Time") {
                $0.hidden = .function(["TimeNotification"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "TimeNotification")
                    return row.value ?? false == false
                })
                $0.title = "時刻"
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
                row.hidden = .function(["TimeNotification"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "TimeNotification")
                    return row.value ?? false == false
                })
                row.title = "日時通知を保存"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: SettingViewController.save \(error)のため処理は行いません")
                    }else{
                        self?.save()
                    }
            }
 
            +++ Section("場所")
            <<< SwitchRow("LocationNotification") {
                $0.title = "指定場所で通知"
                if UserDefaults.standard.object(forKey: DefaultString.NoticeLocationFlag) != nil {
                    $0.value = UserDefaults.standard.bool(forKey: DefaultString.NoticeLocationFlag)
                }else{
                    $0.value = false
                }
                }.onChange { row in
                    if row.value! == false {
                        // 通知OFF
                        let identifiers = ["BiBittoLocationNotification"]
                        UNUserNotificationCenter.current().removeNotificationsCompletely(withIdentifiers: identifiers)
                        UserDefaults.standard.set(false ,forKey: DefaultString.NoticeLocationFlag)
                    }

            }
            <<< DetailedButtonRow("SelectLocation") { row in
                row.hidden = .function(["LocationNotification"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "LocationNotification")
                    return row.value ?? false == false
                })
                row.title = "場所"
                row.presentationMode = .segueName(segueName: "MapViewControllerSegue", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.detailTextLabel?.text = self.selectedLocationName
                })

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.hidden = .function(["LocationNotification"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "LocationNotification")
                    return row.value ?? false == false
                })
                row.title = "場所通知を保存"
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
        print("cancel tapped")
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
        let dataComps = cal.dateComponents([.hour, .minute], from: inputTime)
        
        // トリガー設定
        if inputRepeat == RepeatInterval.Every_Day {
            trigger = UNCalendarNotificationTrigger(dateMatching: dataComps, repeats: true)
        }else{
            trigger = UNCalendarNotificationTrigger(dateMatching: dataComps, repeats: false)
        }
        
        // 通知内容の設定
        content.title = "ビビッとくる！俺の名言コレクション"
        // カード一覧をローカルファイルから取得
        let cardDataArray = CardFileIntermediary.getList()
        if cardDataArray.count > 0 ,!cardDataArray.isEmpty, let text = cardDataArray.shuffled.first?.text {
            content.body = text
        }else{
            content.body = "今日のビビッとくる名言は？"
        }
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "BiBittoTimeNotification", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        UserDefaults.standard.set(true ,forKey: DefaultString.NoticeTimeFlag)
        
        print("DEBUG_PRINT: SettingViewController registerLocalNotification end")
    }
    
    @IBAction func saveLocation() {
        print("DEBUG_PRINT: SettingViewController saveLocation start")

        if self.selectedLatitude == nil || self.selectedLongitude == nil {
            // エラーポップアップ
            SVProgressHUD.showError(withStatus: "場所が指定されていません")
            return
        }
        registerLocationLocalNotification()
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        
        print("DEBUG_PRINT: SettingViewController saveLocation end")
    }
    
    func registerLocationLocalNotification() {
        print("DEBUG_PRINT: SettingViewController registerLocationLocalNotification start")
        
        // UNMutableNotificationContent 作成
        let content = UNMutableNotificationContent()
        content.title = "ビビッとくる！俺の名言コレクション"
        // カード一覧をローカルファイルから取得
        let cardDataArray = CardFileIntermediary.getList()
        if cardDataArray.count > 0 ,!cardDataArray.isEmpty, let text = cardDataArray.shuffled.first?.text {
            content.body = text
        }else{
            content.body = "今日のビビッとくる名言は？"
        }
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        // UNLocationNotificationTrigger 作成
        //「中心座標 (35.697275, 139.774728)」「半径 100m」の円に入った時の例
        let coordinate = CLLocationCoordinate2DMake(Double(self.selectedLatitude!)!,Double(self.selectedLongitude!)!)
        let region = CLCircularRegion.init(center: coordinate, radius: 50, identifier: self.selectedLocationName!)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
        
        // id, content, trigger から UNNotificationRequest 作成
        let request = UNNotificationRequest.init(identifier: "BiBittoLocationNotification", content: content, trigger: trigger)
        
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        UserDefaults.standard.set(true ,forKey: DefaultString.NoticeLocationFlag)

        print("DEBUG_PRINT: SettingViewController registerLocationLocalNotification end")
    }

}

public final class DetailedButtonRowOf<T: Equatable> : _ButtonRowOf<T>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellStyle = .value1
    }
}
public typealias DetailedButtonRow = DetailedButtonRowOf<String>

extension UNUserNotificationCenter {
    func removeNotificationsCompletely(withIdentifiers identifiers: [String]) {
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
