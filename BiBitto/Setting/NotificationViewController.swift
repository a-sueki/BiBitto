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
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: NotificationViewController viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        // 位置情報取得サービスセットアップ
        locationManager = CLLocationManager() // インスタンスの生成
        locationManager.delegate = self // CLLocationManagerDelegateプロトコルを実装するクラスを指定する

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
            Section("日時")
            <<< SwitchRow("TimeNotification") {
                $0.title = "日時で通知する"
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
                $0.title = "場所で通知する"
                if UserDefaults.standard.object(forKey: DefaultString.NoticeFlag) != nil {
                    $0.value = UserDefaults.standard.bool(forKey: DefaultString.NoticeFlag)
                }else{
                    $0.value = true
                }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
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
        content.body = "今日のビビッとくる言葉は？"
        content.sound = UNNotificationSound.default()
        content.badge = 0
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "BiBittoTimeNotification", content: content, trigger: trigger)
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
        
        // UNMutableNotificationContent 作成
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "Enter Headquarter"
        content.sound = UNNotificationSound.default()
        
        // UNLocationNotificationTrigger 作成
        //「中心座標 (35.697275, 139.774728)」「半径 1000m」の円に入った時の例
        //let coordinate = CLLocationCoordinate2DMake(35.697275, 139.774728)
        //let region = CLCircularRegion.init(center: coordinate, radius: 1000.0, identifier: "Headquarter")

        let coordinate = CLLocationCoordinate2DMake(35.605879,139.481293)
        let region = CLCircularRegion.init(center: coordinate, radius: 100, identifier: "Kurihira")
//        region.notifyOnEntry = true
//        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
        
        // id, content, trigger から UNNotificationRequest 作成
        let request = UNNotificationRequest.init(identifier: "BiBittoLocationNotification", content: content, trigger: trigger)
        
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        
        print("DEBUG_PRINT: SettingViewController registerLocationLocalNotification end")
    }

}
extension NotificationViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("DEBUG_PRINT: SettingViewController didChangeAuthorization start")

        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // アプリケーションに関してまだ選択されていない
            //locationManager.requestWhenInUseAuthorization() // 起動中のみの取得許可を求める
            locationManager.requestAlwaysAuthorization() // 常時取得の許可を求める
            
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の設定
            locationManager.allowsBackgroundLocationUpdates = true // バックグランドモードで使用する場合YESにする必要がある
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 位置情報取得の精度
            locationManager.distanceFilter = 1 // 位置情報取得する間隔、1m単位とする
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の設定
            locationManager.allowsBackgroundLocationUpdates = true // バックグランドモードで使用する場合YESにする必要がある
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 位置情報取得の精度
            locationManager.distanceFilter = 1 // 位置情報取得する間隔、1m単位とする
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        }

        print("DEBUG_PRINT: SettingViewController didChangeAuthorization end")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("DEBUG_PRINT: SettingViewController didUpdateLocations start")

        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        print("latitude: \(latitude!)\nlongitude: \(longitude!)")

        print("DEBUG_PRINT: SettingViewController didUpdateLocations end")
    }
}
