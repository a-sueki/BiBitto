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

    var inputData = [String : Any]()
    var lastUpdated = UserDefaults.standard.object(forKey: DefaultString.CardMetaUpdated) ?? "なし"
    var cardDataArray: [CardData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BackupViewController viewDidLoad start")

        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: BackupViewController viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: BackupViewController viewWillAppear start")

        if let date = UserDefaults.standard.object(forKey: DefaultString.CardMetaUpdated) {
            self.lastUpdated = date
        }else{
            self.lastUpdated = "なし"
        }

        let restoreSection: Section = form.allSections[2]
        restoreSection.footer?.title = "最終保存日時:\(self.lastUpdated)"
        restoreSection.reload()
        
        print("DEBUG_PRINT: BackupViewController viewWillAppear end")
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
            Section("自動")
            <<< SwitchRow("autoBackup"){
                $0.title = "自動保存"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.AutoBackup)
                }.onChange { row in
                    self.autoBackupSetting()
            }
            
        +++ Section("手動")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "現在の内容を保存"
                }.onCellSelection { [weak self] (cell, row) in
                    if Auth.auth().currentUser == nil {
                        SVProgressHUD.showError(withStatus: Alert.pleaseloginAlartTitle)
                    }else{
                        self?.save()
                    }
        }
            +++ Section(header:"復元", footer:"最終保存日時:\(self.lastUpdated)" ){
                $0.tag = "restoreButton"
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "バックアップから復元"
                }.onCellSelection { [weak self] (cell, row) in
                    if Auth.auth().currentUser == nil {
                        SVProgressHUD.showError(withStatus: Alert.pleaseloginAlartTitle)
                    }else{
                        self?.restore()
                    }
        }
        
        print("DEBUG_PRINT: BackupViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    @IBAction func autoBackupSetting() {
        print("DEBUG_PRINT: BackupViewController autoBackupSetting start")
        
        for (key,value) in form.values() {
            if value != nil {
                inputData["\(key)"] = value
            }
        }
        UserDefaults.standard.set(inputData["autoBackup"] as! Bool, forKey: DefaultString.AutoBackup)
        
        print("DEBUG_PRINT: BackupViewController autoBackupSetting end")
    }
    
    @IBAction func save() {
        print("DEBUG_PRINT: BackupViewController save start")
        
        SVProgressHUD.show(withStatus: Alert.waiting)
        // 遅延実行
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter( deadline: dispatchTime) {
            
            // ログインしている場合、firebaseStorageにupdate
            if let uid = Auth.auth().currentUser?.uid {
                // ストレージに保存
                StorageProcessing.storageUpload(fileType: Files.card_file, key: uid)
                StorageProcessing.storageUpload(fileType: Files.word_file, key: uid)
                print("DEBUG_PRINT: BackupViewController FB Storage uploaded!")
            }
            
            // 全てのモーダルを閉じる
            SVProgressHUD.dismiss()
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            // Home画面に戻る（選択済みにする）
            let nav = self.navigationController!
            nav.viewControllers[nav.viewControllers.count-2].tabBarController?.selectedIndex = 1
            // 成功ポップアップ
            SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        }
        
        print("DEBUG_PRINT: BackupViewController save end")
    }
    
    @IBAction func restore() {
        print("DEBUG_PRINT: BackupViewController restore start")
        
        SVProgressHUD.show(withStatus: Alert.waiting)
        // 遅延実行
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter( deadline: dispatchTime) {
            // ログインしている場合、firebaseStorageからdownload
            if let uid = Auth.auth().currentUser?.uid {
                // ストレージから取得
                StorageProcessing.storageDownload(fileType: Files.card_file, key: uid)
                StorageProcessing.storageDownload(fileType: Files.word_file, key: uid)
                print("DEBUG_PRINT: BackupViewController FB Storage uploaded!")
 
                self.cardDataArray = Files.readCardDocument(fileName: Files.card_file)
                // 他画面での参照用配列をアップデート
                CardFileIntermediary.setList(list: self.cardDataArray)
            }
            // 全てのモーダルを閉じる
            SVProgressHUD.dismiss()
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            // Home画面に戻る（選択済みにする）
            let nav = self.navigationController!
            nav.viewControllers[nav.viewControllers.count-2].tabBarController?.selectedIndex = 1
            // 成功ポップアップ
            SVProgressHUD.showSuccess(withStatus: Alert.successRestoreTitle)
        }
        
        print("DEBUG_PRINT: BackupViewController restore end")
    }

}
