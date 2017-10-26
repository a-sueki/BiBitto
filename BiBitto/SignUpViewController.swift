//
//  SignUpViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Presentr
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = TransitionType.coverHorizontalFromRight
        presenter.dismissOnSwipe = true
        return presenter
    }()
    
    lazy var emailValidationController: AlertViewController = {
        let alertController = Presentr.alertViewController(title: "⚠️入力エラー", body: "メールアドレスが不正です")
        let okAction = AlertAction(title: "OK", style: .cancel) {
            print("OK")
        }
        alertController.addAction(okAction)
        return alertController
    }()
    
    lazy var existingEmailValidationController: AlertViewController = {
        let alertController = Presentr.alertViewController(title: "⚠️入力エラー", body: "そのメールアドレスは既に登録されています")
        let okAction = AlertAction(title: "OK", style: .cancel) {
            print("OK")
        }
        alertController.addAction(okAction)
        return alertController
    }()
    
    lazy var passwordValidationController: AlertViewController = {
        let alertController = Presentr.alertViewController(title: "⚠️入力エラー", body: "パスワードは6~12文字で設定してください")
        let okAction = AlertAction(title: "OK", style: .cancel) {
            print("OK")
        }
        alertController.addAction(okAction)
        return alertController
    }()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: SignUpViewController viewDidLoad start")

        // textFiel の情報を受け取るための delegate を設定
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        print("DEBUG_PRINT: SignUpViewController viewDidLoad end")
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
            if email!.characters.isEmpty || isValidEmailAddress(emailAddressString: email!) == false {
                showAlert(alertViewController: emailValidationController)
                return
            }
        }else{
            showAlert(alertViewController: emailValidationController)
            return
        }
        if password != nil {
            if password!.characters.count < 6 || password!.characters.count > 12{
                showAlert(alertViewController: passwordValidationController)
                return
            }
        }else{
            showAlert(alertViewController: passwordValidationController)
            return
        }
        
        // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
        Auth.auth().createUser(withEmail: email!, password: password!) { user, error in
            if let error = error {
                // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                print("DEBUG_PRINT: SignUpViewController createUser " + error.localizedDescription)
                if error.localizedDescription.contains("already in use") {
                    self.showAlert(alertViewController: self.existingEmailValidationController)
                } else {
                    self.showAlert(alertViewController: self.emailValidationController)
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
                // 確認メール送信
                if !user.isEmailVerified {
                    print("DEBUG_PRINT: SignUpViewController sendEmailVerification ")
                    DispatchQueue.global().async {
                        user.sendEmailVerification(completion: nil)
                    }
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
    
    func showAlert(alertViewController: AlertViewController) {
        print("DEBUG_PRINT: SignUpViewController showAlert start")

        presenter.presentationType = .alert
        presenter.transitionType = nil
        presenter.dismissTransitionType = nil
        presenter.dismissAnimated = true
        customPresentViewController(presenter, viewController: alertViewController, animated: true, completion: nil)

        print("DEBUG_PRINT: SignUpViewController showAlert end")
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        print("DEBUG_PRINT: SignUpViewController isValidEmailAddress start")

        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }

        print("DEBUG_PRINT: SignUpViewController isValidEmailAddress end")
        return  returnValue
    }
}


// MARK: - Presentr Delegate

extension SignUpViewController: PresentrDelegate {
    
    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        print("DEBUG_PRINT: SignUpViewController presentrShouldDismiss start")
        print("DEBUG_PRINT: SignUpViewController presentrShouldDismiss end")
        return !keyboardShowing
    }
    
}

// MARK: - UITextField Delegate

extension SignUpViewController: UITextFieldDelegate {
    
    // Returnキーでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("DEBUG_PRINT: SignUpViewController textFieldShouldReturn start")

        textField.resignFirstResponder()

        print("DEBUG_PRINT: SignUpViewController textFieldShouldReturn end")
        return true
    }
    
    // TextField以外の部分をタッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("DEBUG_PRINT: SignUpViewController touchesBegan start")

        self.view.endEditing(true)

        print("DEBUG_PRINT: SignUpViewController touchesBegan end")
    }
    
}


