//
//  Const.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Foundation
import Presentr

struct Paths {
    static let UserPath = "user"
    static let CardPath = "card"
}

struct DefaultString {
    static let NoticeFlag = "noticeFlag"

    //static let Uid = "uid"
    static let Mail = "mail"
    static let Password = "password"
    static let Backup = "backup"
}
struct ErrorMsgString {
    static let RulePassword = "パスワードは6~12文字で設定して下さい"
}

struct ValidEmailAddress {
    static func isValidEmailAddress(emailAddressString: String) -> Bool {
        print("DEBUG_PRINT: isValidEmailAddress start")
        
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
        print("DEBUG_PRINT: isValidEmailAddress end")
        return  returnValue
    }
}

struct PresentrAlert {
    static let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = TransitionType.coverHorizontalFromRight
        presenter.dismissOnSwipe = true
        return presenter
    }()
}
    
struct Alert {
    static let validationTitle = "⚠️入力エラー"
    static let validationEmail = "メールアドレスが不正です"
    static let validationExistingEmail = "そのメールアドレスは既に登録されています"
    static let validationPassword = "パスワードは6~12文字で設定してください"

    static let loginAlartTitle = "⚠️ログインしていません"
    static let loginAlartBody = " バックアップを有効にするには、[アカウント] からログインして下さい"

    static let successSaveTitle = "✅保存しました"
    static let successSendTitle = "✅送信しました"
    static let successLoginTitle = "✅ログインしました"
    static let successLogoutTitle = "✅ログアウトしました"
    
    static func setAlertController(title: String, message: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        return alertController
    }
}
