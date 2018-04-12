//
//  PasswordResetViewController.swift
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

class PasswordResetViewController: FormViewController {
    
    var inputData = [String : Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: PasswordResetViewController viewDidLoad start")

        initializeForm()
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))

        print("DEBUG_PRINT: PasswordResetViewController viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeForm(){
        print("DEBUG_PRINT: PasswordResetViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section("パスワードのリセット")
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
         
            +++ Section("上記のメールアドレスに新しいパスワードを送信します")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "OK"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: ログイン \(error)のため処理は行いません")
                    }else{
                        self?.ok()
                    }
        }
        print("DEBUG_PRINT: PasswordResetViewController initializeForm end")
    }
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }

    @IBAction func ok(){
        print("DEBUG_PRINT: PasswordResetViewController ok start")
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
            }
        }
        let email = self.inputData["mail"] as! String

        // 入力チェック
        if email.isEmpty || ValidEmailAddress.isValidEmailAddress(emailAddressString: email) == false {
            SVProgressHUD.showError(withStatus: Alert.validationEmail)
            return
        }
        
        // パスワードの再設定メールを送信する
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print("DEBUG_PRINT: PasswordResetViewController sendPasswordResetでエラー：\(error)")
            }
            // UserDefaultにアカウント情報を保存
            UserDefaults.standard.set(email, forKey: DefaultString.Mail)
            UserDefaults.standard.removeObject(forKey: DefaultString.Password)

        }
        
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSendTitle)
        // 前画面に戻る
        self.navigationController?.popViewController(animated: false)
        
        print("DEBUG_PRINT: PasswordResetViewController ok end")
    }    
}
