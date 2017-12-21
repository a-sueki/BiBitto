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
    
    static let Uid = "uid"
    static let Mail = "mail"
    static let Password = "password"
    static let Backup = "backup"
    static let CardDataArray = "cardDataArray"
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
    static let successRestoreTitle = "✅データの復元に成功しました"
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
struct Category {
    static let continents = ["MINDE", "LEADERSHIP", "VISION", "WISDOM", "FELLOW"]
}

struct ShareString {
    static let text = "#俺のビビッとくるアプリ "
    static let website = NSURL(string: "https://www.apple.co.jp")! //TODO1
    static let excludedActivityTypes = [
        UIActivityType.postToWeibo,
        UIActivityType.saveToCameraRoll,
        UIActivityType.print,
        UIActivityType.copyToPasteboard,
        UIActivityType.airDrop,
        UIActivityType.assignToContact,
        UIActivityType.addToReadingList,
        UIActivityType.mail,
        UIActivityType.message
    ]
}
struct Tokenizer {
    
    // MARK: - Properties
    private static let scheme = NSLinguisticTagScheme.tokenType.rawValue
    private static let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
    
    // MARK: - Publics
    static func tokenize(text: String) -> [String] {
        let range = text.startIndex ..< text.endIndex
        var tokens: [String] = []
        
        /*        text.enumerateLinguisticTagsInRange(range, scheme: scheme, options: options, orthography: nil) { (_, range, _, _) in
         let token = text.substringWithRange(range)
         tokens.append(token)
         }
         */
        text.enumerateLinguisticTags(in: range, scheme: scheme, options: options, orthography: nil, invoking:{(_, range, _, _) in
            //let token = text.substringWithRange(range)
            let token = text[text.startIndex ..< text.endIndex]
            tokens.append(String(token))
        })
        return tokens
    }
}


struct Files {
    
    static let file_name = "data.txt"
    
    // Documentフォルダにファイルを全件クリア
    static func refreshDocument() {
        print("DEBUG_PRINT: refreshDocument start")
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( file_name )
            do {
                try "".write(to: path_file_name, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                //エラー処理
            }
        }
    }
    // Documentフォルダにファイルを保存
    static func writeDocument(dataArray : [String]) {
        print("DEBUG_PRINT: writeDocument start")

        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( file_name )
            do {
                for  text in dataArray {
                    try text.appendLineToURL(fileURL: path_file_name as URL)
                }
            } catch {
                //エラー処理
            }
        }
    }
    // Documentフォルダからファイルを読み込み
    static func readDocument() -> [String] {
        print("DEBUG_PRINT: readDocument start")
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( file_name )
            do {
                let contents = try String(contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                if !contents.isEmpty {
                    let words = contents.characters.split(separator: "\n")
                    return words.map(String.init)
                }
            } catch {
                //エラー処理
            }
        }
        return []
    }
}

// ファイルの末尾に追記
extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}
extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
