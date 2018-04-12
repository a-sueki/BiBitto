//
//  AccountViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import SVProgressHUD
import Eureka
import Firebase
import FirebaseAuth

class AccountViewController: FormViewController {
    
    var inputData = [String : Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: AccountViewController viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: AccountViewController viewDidLoad end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initializeForm(){
        print("DEBUG_PRINT: AccountViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section("アカウント")
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
            
            +++ Section(){
                $0.hidden = .function([""], { form -> Bool in
                    if Auth.auth().currentUser == nil {
                        return false
                    }else{
                        return true
                    }
                })
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "ログイン"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: ログイン \(error)のため処理は行いません")
                    }else{
                        self?.login()
                    }
            }

            +++ Section(){
                $0.hidden = .function([""], { form -> Bool in
                    if Auth.auth().currentUser != nil {
                        return false
                    }else{
                        return true
                    }
                })
            }
            
         <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "変更を保存"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: 変更 \(error)のため処理は行いません")
                    }else{
                        self?.save()
                    }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "ログアウト"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: ログアウト \(error)のため処理は行いません")
                    }else{
                        self?.logout()
                    }
            }
            
            +++ Section()
            <<< ButtonRow("PasswordReset") { (row: ButtonRow) -> Void in
                row.title = "パスワードをリセット"
                row.presentationMode = .segueName(segueName: "PasswordResetControllerSegue", onDismiss: nil)
        }

        print("DEBUG_PRINT: AccountViewController initializeForm end")
    }

    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }

    @IBAction func login(){
        print("DEBUG_PRINT: AccountViewController login start")
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
            }
        }
        
        let email = self.inputData["mail"] as! String
        let password = self.inputData["password"] as! String
        
        // 入力チェック
        if email.isEmpty || ValidEmailAddress.isValidEmailAddress(emailAddressString: email) == false {
            SVProgressHUD.showError(withStatus: Alert.validationEmail)
            return
        }
        if password.count < 6 || password.characters.count > 12{
            SVProgressHUD.showError(withStatus: Alert.validationEmail)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error {
                print("DEBUG_PRINT: " + error.localizedDescription)
                return
            } else {
                print("DEBUG_PRINT: ログインに成功しました")
                // UserDefaultにアカウント情報を保存
                UserDefaults.standard.set(user?.uid, forKey: DefaultString.Uid)
                UserDefaults.standard.set(email, forKey: DefaultString.Mail)
                UserDefaults.standard.set(password, forKey: DefaultString.Password)
                // 成功ポップアップ
                SVProgressHUD.showSuccess(withStatus: Alert.successLoginTitle)
                // 前画面に戻る
                self.navigationController?.popViewController(animated: false)
            }
        }
        
        print("DEBUG_PRINT: AccountViewController login end")
    }

    @IBAction func save() {
        print("DEBUG_PRINT: SettingViewController.save start")
 
        // アカウント情報の修正
        for (key,value) in form.values() {
            if value != nil {
                if key == DefaultString.Mail {
                    if UserDefaults.standard.string(forKey: DefaultString.Mail) != value as? String {
                        if let user = Auth.auth().currentUser {
                            user.updateEmail(to: value as! String, completion: { error in
                                if let error = error {
                                    print("DEBUG_PRINT: " + error.localizedDescription)
                                }
                                print("DEBUG_PRINT: [email = \(user.email!)]の設定に成功しました。")
                                // ユーザーデフォルト設定（アカウント項目）
                                UserDefaults.standard.set(value , forKey: DefaultString.Mail)
                            })
                        } else {
                            print("DEBUG_PRINT: メールアドレス変更なし")
                        }
                    }
                    // パスワードを設定する
                }else if key == "password" {
                    if UserDefaults.standard.string(forKey: DefaultString.Password) != value as? String {
                        if let user = Auth.auth().currentUser {
                            user.updatePassword(to: value as! String, completion: { error in
                                if let error = error {
                                    print("DEBUG_PRINT: " + error.localizedDescription)
                                }
                                print("DEBUG_PRINT: パスワードの更新に成功しました。")
                                // ユーザーデフォルト設定（アカウント項目）
                                UserDefaults.standard.set(value , forKey: DefaultString.Password)
                            })
                        } else {
                            print("DEBUG_PRINT: パスワード変更なし")
                        }
                    }
                }
            }
        }
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        // 前画面に戻る
        self.navigationController?.popViewController(animated: false)

        print("DEBUG_PRINT: SettingViewController.save end")
    }
    
    @IBAction func logout(){
        print("DEBUG_PRINT: AccountViewController logout start")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)

        // ログアウト
        do {
            try Auth.auth().signOut()
        }catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successLogoutTitle)
        // 前画面に戻る
        self.navigationController?.popViewController(animated: false)

        print("DEBUG_PRINT: AccountViewController logout end")
    }
}
