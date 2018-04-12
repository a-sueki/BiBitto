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
import SVProgressHUD

class SettingViewController: FormViewController {
    
    var inputData = [String : Any]()

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
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "通知"
                row.presentationMode = .segueName(segueName: "NotificationViewControllerSegue", onDismiss: nil)
            }

            +++ Section("アカウント")
            <<< ButtonRow("Account") { (row: ButtonRow) -> Void in
                row.title = "アカウント"
                row.presentationMode = .segueName(segueName: "AccountControllerSegue", onDismiss: nil)
            }

            +++ Section(header:"データ管理", footer:"オンラインバックアップの利用にはログインしている必要があります。" )
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "ファイルから一括取込"
                row.presentationMode = .segueName(segueName: "ImportDataViewControllerSegue", onDismiss: nil)
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "オンラインバックアップ"
                row.presentationMode = .segueName(segueName: "BackupViewControllerSegue", onDismiss: nil)
        }

        print("DEBUG_PRINT: SettingViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
}

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}
