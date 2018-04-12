//
//  BackupViewController.swift
//  BiBitto
//
//  Created by admin on 2018/04/12.
//  Copyright © 2018年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseAuth
import SVProgressHUD


class BackupViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BackupViewController viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: BackupViewController viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeForm(){
        print("DEBUG_PRINT: BackupViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section(header:"復元", footer:"最終保存日時:\(UserDefaults.standard.object(forKey: DefaultString.CardMetaUpdated)!)" )
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "オンラインバックアップから復元"
                // ログインしてない場合、非活性にして表示
                row.disabled = .function([""], { form -> Bool in
                    if Auth.auth().currentUser != nil {
                        return false
                    }else{
                        return true
                    }
                })
                }.onCellSelection { [weak self] (cell, row) in
                    self?.restore()
            }
        
        +++ Section("保存")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "現在の内容をバックアップに保存"
                // ログインしてない場合、非活性にして表示
                row.disabled = .function([""], { form -> Bool in
                    if Auth.auth().currentUser != nil {
                        return false
                    }else{
                        return true
                    }
                })
                }.onCellSelection { [weak self] (cell, row) in
                    self?.save()
        }

        
        print("DEBUG_PRINT: BackupViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    
    @IBAction func restore() {
        print("DEBUG_PRINT: BackupViewController restore start")
        
        // ログインしている場合、firebaseStorageからdownload
        if let uid = Auth.auth().currentUser?.uid {
            // ストレージから取得
            StorageProcessing.storageDownload(fileType: Files.card_file, key: uid)
            StorageProcessing.storageDownload(fileType: Files.word_file, key: uid)
            print("DEBUG_PRINT: BackupViewController FB Storage uploaded!")
        }
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // Home画面に戻る（選択済みにする）
        let nav = self.navigationController!
        nav.viewControllers[nav.viewControllers.count-2].tabBarController?.selectedIndex = 1
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successRestoreTitle)
        
        print("DEBUG_PRINT: BackupViewController restore end")
    }

    @IBAction func save() {
        print("DEBUG_PRINT: BackupViewController save start")
        
        // ログインしている場合、firebaseStorageにupdate
        if let uid = Auth.auth().currentUser?.uid {
            // ストレージに保存
            StorageProcessing.storageUpload(fileType: Files.card_file, key: uid)
            StorageProcessing.storageUpload(fileType: Files.word_file, key: uid)
            print("DEBUG_PRINT: BackupViewController FB Storage uploaded!")
        }
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // Home画面に戻る（選択済みにする）
        let nav = self.navigationController!
        nav.viewControllers[nav.viewControllers.count-2].tabBarController?.selectedIndex = 1
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        
        
        print("DEBUG_PRINT: BackupViewController save end")
    }

}
