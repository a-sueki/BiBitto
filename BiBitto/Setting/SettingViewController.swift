//
//  SettingViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseAuth
import UserNotifications
import SVProgressHUD

class SettingViewController: FormViewController {
    
    var inputData = [String : Any]()
    var autoBackupFlag = false
        
    lazy var signUpViewController: SignUpViewController = {
        let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController")
        return signUpViewController as! SignUpViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: SettingViewController viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: SettingViewController viewDidLoad end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initializeForm(){
        print("DEBUG_PRINT: SettingViewController initializeForm start")
        
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
            
            +++ Section("アカウント")
            <<< ButtonRow("Account") { (row: ButtonRow) -> Void in
                row.title = "アカウント"
                row.presentationMode = .segueName(segueName: "AccountControllerSegue", onDismiss: nil)
            }
            
            +++ Section("バックアップ")
            <<< SwitchRow("AutoBackup") {
                $0.title = "自動バックアップをONにする"
                if Auth.auth().currentUser == nil {
                    $0.value = false
                }else{
                    $0.value = true
                }
                }.onChange { [weak self] in
                    if $0.value == true {
                        self?.autoBackupFlag = true
                        if UserDefaults.standard.object(forKey: DefaultString.Mail) == nil {
                            self?.signUp()
                        }
                    }
            }

            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "バックアップから復元する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: SettingViewController.restore \(error)のため処理は行いません")
                    }else{
                        if Auth.auth().currentUser == nil {
                            SVProgressHUD.showSuccess(withStatus: Alert.loginAlartTitle)
                        }else{
                            self?.restore()
                        }
                    }
            }

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "設定を保存する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: SettingViewController.save \(error)のため処理は行いません")
                    }else{
                        if (self?.autoBackupFlag)!, Auth.auth().currentUser == nil {
                            SVProgressHUD.showSuccess(withStatus: Alert.loginAlartTitle)
                        }else{
                            self?.save()
                        }
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
        UserDefaults.standard.set(inputData["AutoBackup"], forKey: DefaultString.AutoBackup)
        registerLocalNotification(inputData: inputData)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)

        print("DEBUG_PRINT: SettingViewController save end")
    }
    
    @IBAction func restore() {
        print("DEBUG_PRINT: SettingViewController restore start")
        
        var cardDataArray: [CardData] = []
        // Firebaseからデータを取得し、UserDefaultにセット
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child(Paths.CardPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: SettingViewController restore .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let cardData = CardData(snapshot: snapshot)
                    cardDataArray.append(cardData)
                }
                // UserDefaultにセット
                DispatchQueue.main.async {
                    print("DEBUG_PRINT: SettingViewController restore [DispatchQueue.main.async]")

                    print(cardDataArray)
                    UserDefaults.standard.set(cardDataArray, forKey: DefaultString.CardDataArray)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successRestoreTitle)
        
        print("DEBUG_PRINT: SettingViewController restore end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: SettingViewController viewWillDisappear start")
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child(Paths.CardPath).child(uid)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: SettingViewController viewWillDisappear end")
    }

    
    func registerLocalNotification(inputData: [String : Any]) {
        print("DEBUG_PRINT: SettingViewController registerLocalNotification start")

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
        content.body = "今日のビビッとくる言葉は？"
        content.sound = UNNotificationSound.default()
        content.badge = 0
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "BiBittoNotification", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        print("DEBUG_PRINT: SettingViewController registerLocalNotification end")
    }
    
    func signUp() {
        print("DEBUG_PRINT: SettingViewController signUp start")
        
        PresentrAlert.presenter.presentationType = .popup
        PresentrAlert.presenter.transitionType = nil
        PresentrAlert.presenter.dismissTransitionType = nil
        PresentrAlert.presenter.keyboardTranslationType = .compress
        PresentrAlert.presenter.dismissOnSwipe = true
        customPresentViewController(PresentrAlert.presenter, viewController: signUpViewController, animated: true, completion: nil)
        
        print("DEBUG_PRINT: SettingViewController signUp end")
    }
}

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}
