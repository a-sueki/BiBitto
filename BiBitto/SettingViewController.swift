//
//  SettingViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka

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
            <<< SwitchRow("notification") {
                $0.title = "通知をオンにする"
                if UserDefaults.standard.object(forKey: DefaultString.NoticeFlag) != nil {
                    $0.value = UserDefaults.standard.bool(forKey: DefaultString.NoticeFlag)
                }else{
                    $0.value = true
                }
            }
            +++ Section("時刻で設定"){
                $0.hidden = .function(["notification"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "notification")
                    return row.value ?? false == false
                })
            }
            <<< TimeInlineRow("Time") {
                $0.title = "通知時刻"
                $0.value = Date().addingTimeInterval(60*60*24)
                }
            <<< PushRow<RepeatInterval>("Repeat") {
                $0.title = "繰り返し"
                $0.options = RepeatInterval.allValues
                $0.value = .Every_Day
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })


        form +++
            
            MultivaluedSection(multivaluedOptions: [.Insert, .Delete, .Reorder],
                               header: "Multivalued Push Selector example",
                               footer: "") {
                                $0.tag = "push"
                                $0.multivaluedRowToInsertAt = { index in
                                    return PushRow<String>{
                                        $0.title = "Tap to select ;)..at \(index)"
                                        $0.options = ["Option 1", "Option 2", "Option 3"]
                                    }
                                }
                                $0 <<< PushRow<String> {
                                    $0.title = "Tap to select ;).."
                                    $0.options = ["Option 1", "Option 2", "Option 3"]
                                }
                                
            }

            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "保存"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: UserViewController.updateUserData \(error)のため処理は行いません")
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
        case Never = "しない"
        case Every_Day = "毎日"
        case Every_Week = "毎週"
        case Every_2_Weeks = "隔週"
        case Every_Month = "毎月"
        case Every_Year = "毎年"
        
        var description : String { return rawValue }
        
        static let allValues = [Never, Every_Day, Every_Week, Every_2_Weeks, Every_Month, Every_Year]
    }
    
    @IBAction func save() {
        print("DEBUG_PRINT: SettingViewController.save start")
        
        for (key,value) in form.values() {
            if value != nil {
                inputData["\(key)"] = value
            }
        }
        
        print(inputData["push"])
        
        // UserDefaultsを更新
        // UserDefaults.standard.set(false, forKey: DefaultString.GuestFlag)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        print("DEBUG_PRINT: SettingViewController.save end")
    }
}

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}
