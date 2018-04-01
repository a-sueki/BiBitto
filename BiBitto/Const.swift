//
//  Const.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Foundation
import SVProgressHUD
import Presentr

struct Paths {
    static let UserPath = "user"
    static let CardPath = "card"
}

struct DefaultString {
    static let NoticeFlag = "noticeFlag"
    
    static let Uid = "uid"              // FBアカウント（uid）
    static let Mail = "mail"            // FBアカウント（メール）
    static let Password = "password"    // FBアカウント（パスワード）
    static let CardDataArray = "cardDataArray"  // カードデータ
    static let AutoBackup = "autoBackup"    // FBへの自動バックアップ（true:ON）
}
struct ErrorMsgString {
    static let RulePassword = "パスワードは6~12文字で設定して下さい"
}
struct DummyString {
    static let Key = "DummyKey"
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
    static let validationEmail = "メールアドレスが不正です"
    static let validationExistingEmail = "そのメールアドレスは既に登録されています"
    static let validationPassword = "パスワードは6~12文字で設定してください"
    static let loginAlartTitle = "ログインしていません"
    static let successSaveTitle = "保存しました"
    static let successRestoreTitle = "データの復元に成功しました"
    static let successSendTitle = "送信しました"
    static let successLoginTitle = "ログインしました"
    static let successLogoutTitle = "ログアウトしました"
        
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
            } catch let error{
                print("DEBUG_PRINT: refreshDocument: \(error.localizedDescription)")
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
            } catch let error{
                print("DEBUG_PRINT: writeDocument: \(error.localizedDescription)")
            }
        }
    }
    
    // Documentフォルダのファイルにデータを保存（全件洗い替え）
    static func writeCardDocument(cardDataArray: Array<[String:Any]>, fileName: String) {
        print("DEBUG_PRINT: writeCardDocument start")
        print("DEBUG_PRINT: writeCardDocument 0: \(cardDataArray)")
        var jsonStrArray = Array<Any>()
        for card in cardDataArray {
            do {
                print(card)
                let jsonData = try JSONSerialization.data(withJSONObject: card, options: [])
                let jsonStr = String(bytes: jsonData, encoding: .utf8)!
                print("DEBUG_PRINT: 生成されたJSON文字列 =>\(jsonStr)")
                jsonStrArray.append(jsonStr)
                print("DEBUG_PRINT: 生成されたJSON文字列の配列 =>\(jsonStrArray)")
            } catch let error {
                print(error)
            }
        }
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                print("DEBUG_PRINT: writeCardDocument 1: \(path_file_name)")
                
                let jsonArrayData = try JSONSerialization.data(withJSONObject: jsonStrArray, options: [])
                
                print("DEBUG_PRINT: writeCardDocument 2: \(jsonArrayData)")
                let jsonArrayStr = String(bytes: jsonArrayData, encoding: .utf8)!
                print("DEBUG_PRINT: writeCardDocument 3: \(jsonArrayStr)")
                try jsonArrayStr.write(to: path_file_name, atomically: true, encoding: String.Encoding.utf8)
            } catch let error{
                print("DEBUG_PRINT: writeCardDocument: \(error.localizedDescription)")
            }
        }
    }
    // DocumentフォルダからString配列（¥n区切り）を読み込み
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
            } catch let error{
                print("DEBUG_PRINT: readDocument: \(error.localizedDescription)")
            }
        }
        return []
    }
    
    // Documentフォルダからjsonデータ（cardファイル）を読み込み
    static func readCardDocument(fileName: String) -> [CardData] {
        print("DEBUG_PRINT: readCardDocument start")
        
        var cardDataArray: [CardData] = []
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            print("DEBUG_PRINTpath_file_name: \(path_file_name)")
            do {
                let jsondata = try? Data(contentsOf: path_file_name)
                //-- 配列データに変換して
                if jsondata != nil && jsondata?.hashValue != 0 {
                let jsonArray = (try! JSONSerialization.jsonObject(with: jsondata!, options: [])) as! NSArray
                print("DEBUG_PRINTjsonArray: \(jsonArray)")
                for jsonItem in jsonArray {
                    print("1")
                    print(jsonItem)
                    let jsonData: Data =  (jsonItem as AnyObject).data(using: String.Encoding.utf8.rawValue)!
                    print("2")
                    print(jsonData)
                    // パースする
                    let card = try JSONSerialization.jsonObject(with: jsonData)  as! [String : AnyObject]
                    //as! Dictionary<String, Any>
                    print("3")
                    print(card)
                    let cardData = CardData(valueDictionary: card)
                    print("4")
                    print(cardData)
                    cardDataArray.append(cardData)
                }
                }
                
                return cardDataArray
                
            } catch let error{
                print("DEBUG_PRINT: readCardDocument: \(error.localizedDescription)")
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
    
    /// 「漢字」かどうか
    var isKanji: Bool {
        let range = "^[\u{3005}\u{3007}\u{303b}\u{3400}-\u{9fff}\u{f900}-\u{faff}\u{20000}-\u{2ffff}]+$"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }
    
    /// 「ひらがな」かどうか
    var isHiragana: Bool {
        let range = "^[ぁ-ゞ]+$"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }
    
    /// 「カタカナ」かどうか
    var isKatakana: Bool {
        let range = "^[ァ-ヾ]+$"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }

    
    /// 「ひらがな」に変換 ※１
    var toHiragana: String? {
        return self.applyingTransform(.hiraganaToKatakana, reverse: false)
    }
    
    /// 「カタカナ」に変換
    var toKatakana: String? {
        return self.applyingTransform(.hiraganaToKatakana, reverse: true)
    }
    
    /// 「ひらがな」を含むかどうか ※2
    var hasHiragana: Bool {
        guard let hiragana = self.toKatakana else { return false }
        return self != hiragana // １文字でもカタカナに変換されている場合は含まれると断定できる
    }
    
    /// 「カタカナ」を含むかどうか
    var hasKatakana: Bool {
        guard let katakana = self.toHiragana else { return false }
        return self != katakana // １文字でもひらがなに変換されている場合は含まれると断定できる
    }
    /// 漢字を含むかどうか
    var hasKanji: Bool {
        let characters = self.characters.map { String($0) } // String -> [String]
        for moji in characters {
            if moji.isKanji {
                return  true
            }
        }
        return false
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

final class TextConverter {
    private init() {}
    enum JPCharacter {
        case hiragana
        case katakana
        fileprivate var transform: CFString {
            switch self {
            case .hiragana:
                return kCFStringTransformLatinHiragana
            case .katakana:
                return kCFStringTransformLatinKatakana
            }
        }
    }
    
    static func convert(_ text: String, to jpCharacter: JPCharacter) -> String {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = ""
        let locale = CFLocaleCreate(kCFAllocatorDefault, CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, "ja" as CFString))
        let range = CFRangeMake(0, input.utf16.count)
        let tokenizer = CFStringTokenizerCreate(
            kCFAllocatorDefault,
            input as CFString,
            range,
            kCFStringTokenizerUnitWordBoundary,
            locale
        )
        
        var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        while (tokenType.rawValue != 0) {
            if let text = (CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? NSString).map({ $0.mutableCopy() }) {
                CFStringTransform(text as! CFMutableString, nil, jpCharacter.transform, false)
                output.append(text as! String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return output
    }
}
