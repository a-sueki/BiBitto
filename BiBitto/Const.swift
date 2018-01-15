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
    
    static let word_file = "word.txt"
    static let card_file = "card.txt"
    static let excludes = CharacterSet(charactersIn: "!#$%()*+,-./:;=?@[\\]^_`{|}~\t、。　！＃＄％（）＊＋，－．／：；＝？＠［＼］＾＿｀｛｜｝～゛†")

    // Documentフォルダのファイルを全件クリア
    static func refreshDocument(fileName: String) {
        print("DEBUG_PRINT: refreshDocument start")
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                try "".write(to: path_file_name, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                //エラー処理
            }
        }
    }
    // Documentフォルダのファイルにデータを保存（末尾に追記）
    static func writeDocument(dataArray : [String], fileName: String) {
        print("DEBUG_PRINT: writeDocument start")
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                for  text in dataArray {
                    try text.appendLineToURL(fileURL: path_file_name as URL)
                }
            } catch {
                //エラー処理
            }
        }
    }
    
    // Documentフォルダのファイルにデータを保存（末尾に追記）
    static func writeCardDocument(card : [String: Any], fileName: String) {
        print("DEBUG_PRINT: writeCardDocument start")

        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: card, options: [])
                let jsonStr = String(bytes: jsonData, encoding: .utf8)!

                try jsonStr.appendLineToURL(fileURL: path_file_name as URL)
            } catch {
                //エラー処理
            }
        }
    }
    // Documentフォルダからファイルを読み込み
    static func readDocument(fileName: String) -> [String] {
        print("DEBUG_PRINT: readDocument start")
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
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
    
    // Documentフォルダからファイルを読み込み
    static func readCardDocument(fileName: String) -> [CardData] {
        print("DEBUG_PRINT: readCardDocument start")
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            print("DEBUG_PRINTpath_file_name: \(path_file_name)")
            do {
                
                let contents = try String(contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                //let jsonData = try JSONSerialization.data(withJSONObject: contents, options: [])
                if !contents.isEmpty {
                    print("DEBUG_PRINTcontents: \(contents)")
                    
                    let binaryData: Data = contents.data(using: .utf8)!
                
                    // JSONパース。optionsは型推論可(".allowFragmets"等)
                    let jsonData = try JSONSerialization.jsonObject(with:binaryData, options: JSONSerialization.ReadingOptions.allowFragments)
                    print("DEBUG_PRINTjsonData: \(String(describing: jsonData))")

                    let top = jsonData as! [[String : AnyObject]]
                    print("DEBUG_PRINTtop: \(top)")

                    var cardDataArray: [CardData] = []
                    for roop in top {
                        let cardData = CardData(valueDictionary: roop)
                        cardDataArray.append(cardData)
                    }
                    return cardDataArray
                }
            } catch {
                //エラー処理
                print(error.localizedDescription)
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
