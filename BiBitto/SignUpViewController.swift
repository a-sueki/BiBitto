//
//  SignUpViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var EULATextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: SignUpViewController viewDidLoad start")
        
        // textFiel の情報を受け取るための delegate を設定
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        EULATextView.isEditable = false
        if let filePath = Bundle.main.path(forResource: "Policy", ofType: "txt"){
            if let data = NSData(contentsOfFile: filePath){
                EULATextView.text = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!)
            }else{
                print("データなし")
            }
        }
        
        print("DEBUG_PRINT: SignUpViewController viewDidLoad end")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 先頭行を初期表示
        self.EULATextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchSignUpButton(_ sender: Any) {
        print("DEBUG_PRINT: SignUpViewController touchSignUpButton start")
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        // 入力チェック
        if email != nil {
            if email!.characters.isEmpty || ValidEmailAddress.isValidEmailAddress(emailAddressString: email!) == false {
                SVProgressHUD.showError(withStatus: Alert.validationEmail)
                return
            }
        }else{
            SVProgressHUD.showError(withStatus: Alert.validationEmail)
            return
        }
        if password != nil {
            if password!.characters.count < 6 || password!.characters.count > 12{
                SVProgressHUD.showError(withStatus: Alert.validationPassword)
                return
            }
        }else{
            SVProgressHUD.showError(withStatus: Alert.validationPassword)
            return
        }
        
        // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
        Auth.auth().createUser(withEmail: email!, password: password!) { user, error in
            if let error = error {
                // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                print("DEBUG_PRINT: SignUpViewController createUser " + error.localizedDescription)
                if error.localizedDescription.contains("already in use") {
                    SVProgressHUD.showError(withStatus: Alert.validationExistingEmail)
                } else {
                    SVProgressHUD.showError(withStatus: Alert.validationEmail)
                }
                return
            }
            
            let user = Auth.auth().currentUser
            if let user = user {
                // 表示名を設定する
                let changeRequest = user.createProfileChangeRequest()
                let displayName = email!.components(separatedBy:"@")
                print(displayName)
                changeRequest.displayName = displayName[0]
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("DEBUG_PRINT: SignUpViewController createUser " + error.localizedDescription)
                    }
                }
                
                // UserDefaultにアカウント情報を保存
                UserDefaults.standard.set(user.uid, forKey: DefaultString.Uid)
                UserDefaults.standard.set(email, forKey: DefaultString.Mail)
                UserDefaults.standard.set(password, forKey: DefaultString.Password)
                
                // 確認メール送信
                if !user.isEmailVerified {
                    print("DEBUG_PRINT: SignUpViewController sendEmailVerification ")
                    // 成功ポップアップ
                    SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
                    user.sendEmailVerification(completion: nil)

                }
            }
        }
        
        print("DEBUG_PRINT: SignUpViewController touchSignUpButton end")
    }
    
    @IBAction func touchSkipButton(_ sender: Any) {
        print("DEBUG_PRINT: SignUpViewController touchSkipButton start")
        
        dismiss(animated: true, completion: nil)
        
        print("DEBUG_PRINT: SignUpViewController touchSkipButton end")
    }
    
    
}

// MARK: - UITextField Delegate

extension SignUpViewController: UITextFieldDelegate {
    
    // Returnキーでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // TextField以外の部分をタッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


