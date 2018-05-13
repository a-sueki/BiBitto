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
import Firebase
import FirebaseStorage

struct Paths {
    static let UserPath = "user"
    static let CardPath = "card"
}

struct URLs {
    static let HowToUseLink = "https://www.apple.co.jp"
}

struct StorageRef{
    static let storage = Storage.storage()
    static let storageRef = storage.reference(forURL: "gs://bibitto-37cdc.appspot.com/")
    static func getRiversRef(fileType: String,key: String) -> StorageReference {
        let riversRef = storageRef.child("\(fileType)/\(key).txt")
        return riversRef
    }
}

struct CardFileIntermediary{
    static var _cardDataArray:[CardData]?
    static func getList() -> [CardData] {
        return self._cardDataArray!
    }
    static func setList(list: [CardData]) {
        self._cardDataArray = list
    }
}
struct DateConversion {
    
    static let formatter: DateFormatter = DateFormatter()
    static func convertFormat(updateDate: Date ,before: String ,after: String) -> String {
        formatter.dateFormat =  DateFormatter.dateFormat(fromTemplate: after, options: 0, locale: .current)
        let strDate = formatter.string(from: updateDate)
        return strDate
/*
        // 日本語にしか対応できてないのでコメントアウト
        formatter.dateFormat = before
        print("result1....\(strDate)")
        if let date = formatter.date(from: String(strDate)) {
            print("result2....\(date)")
            formatter.dateFormat = after
            return formatter.string(from :date)
        }
        return ""
         */
    }

}
struct StorageProcessing{
    static func storageUpload(fileType: String, key: String){
        if let dir = FileManager.default.urls( for: .libraryDirectory, in: .userDomainMask ).first {
            // File located on disk
            let path_file_name = dir.appendingPathComponent(fileType)
            let fileName = fileType.components(separatedBy: ".")
            
            // Create a reference to the file you want to upload
            let riversRef = StorageRef.getRiversRef(fileType: fileName.first!, key: key)
            
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "text/plain"
            
            // Upload file and metadata
            _ = riversRef.putFile(from: path_file_name, metadata: nil) { metadata, error in
                if let error = error {
                    print("DEBUG_PRINT: ImportDataViewController storageUpload: \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: Alert.errorUploadTitle)
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    if let updateDate = metadata?.updated {
                        let resultStr = DateConversion.convertFormat(updateDate: updateDate ,before: "yyyy/MM/dd HH時mm分ss秒 Z", after: "yyyy-MM-dd HH:mm:ss Z")
                        UserDefaults.standard.set(resultStr, forKey: DefaultString.CardMetaUpdated)
                        if fileType == Files.card_file {
                            UserDefaults.standard.set(resultStr, forKey: DefaultString.CardMetaUpdated)
                        }else{
                            UserDefaults.standard.set(resultStr, forKey: DefaultString.WordMetaUpdated)
                        }
                    }
                }
            }
            
        }
    }
    
    static func storageDownload(fileType: String, key: String){
        if let dir = FileManager.default.urls( for: .libraryDirectory,in: .userDomainMask ).first {
            // File located on disk
            let path_file_name = dir.appendingPathComponent(fileType)
            let fileName = fileType.components(separatedBy: ".")
            
            // Create a reference to the file you want to download
            let islandRef = StorageRef.getRiversRef(fileType: fileName.first!, key: key)
            
            // Download to the local filesystem
            _ = islandRef.write(toFile: path_file_name) { url, error in
                if let error = error {
                    print("DEBUG_PRINT: ImportDataViewController storageDownload: \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: Alert.errorDownloadTitle)
                } else {
                    // Local file URL for "images/island.jpg" is returned
                }
            }
        }
    }
}

struct DefaultString {
    static let NoticeTimeFlag = "noticeTimeFlag"
    static let NoticeLocationFlag = "noticeLocationFlag"
    
    static let Uid = "uid"              // FBアカウント（uid）
    static let Mail = "mail"            // FBアカウント（メール）
    static let Password = "password"    // FBアカウント（パスワード）
    static let CardMetaUpdated = "cardMetaUpdated"
    static let WordMetaUpdated = "wordMetaUpdated"
    static let AutoBackup = "autoBackup"
    // 場所で通知
    static let SelectedLocation = "selectedLocation"
    static let SelectedLatitude = "selectedLatitude"
    static let SelectedLongitude = "selectedLongitude"
    // categorys
    static let Category1 = "category1"
    static let Category2 = "category2"
    static let Category3 = "category3"
    static let Category4 = "category4"
    static let Category5 = "category5"

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
    static let pleaseloginAlartTitle = "バックアップの利用にはログインが必要です"
    static let errorSaveTitle = "保存に失敗しました"
    static let errorRestoreTitle = "復元に失敗しました"
    static let errorImportTitle = "ファイル取込に失敗しました"
    static let errorUploadTitle = "バックアップの保存に失敗しました"
    static let errorDownloadTitle = "復元に失敗しました"
    static let successSaveTitle = "保存しました"
    static let successRestoreTitle = "復元に成功しました"
    static let successImportTitle = "ファイル取込に成功しました"
    static let successSendTitle = "送信しました"
    static let successLoginTitle = "ログインしました"
    static let successLogoutTitle = "ログアウトしました"
    static let waiting = "Now Loading..."
    static let saving = "Now Saving..."
    static let limited = "99件以上はアカウント登録が必要です"
}
struct Category {
/*    static var continent1 = UserDefaults.standard.string(forKey: DefaultString.Category1) ?? "MIND"
    static var continent2 = UserDefaults.standard.string(forKey: DefaultString.Category2) ?? "LEADERSHIP"
    static var continent3 = UserDefaults.standard.string(forKey: DefaultString.Category3) ?? "VISION"
    static var continent4 = UserDefaults.standard.string(forKey: DefaultString.Category4) ?? "WISDOM"
    static var continent5 = UserDefaults.standard.string(forKey: DefaultString.Category5) ?? "FELLOW"
*/
    static let continents = [UserDefaults.standard.string(forKey: DefaultString.Category1) ?? "MIND",UserDefaults.standard.string(forKey: DefaultString.Category2) ?? "LEADERSHIP",UserDefaults.standard.string(forKey: DefaultString.Category3) ?? "VISION",UserDefaults.standard.string(forKey: DefaultString.Category4) ?? "WISDOM",UserDefaults.standard.string(forKey: DefaultString.Category5) ?? "FELLOW"]
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
    
    // Libraryフォルダのファイルを全件クリア
    static func refreshDocument(fileName: String) {
        print("DEBUG_PRINT: refreshDocument start")
        
        if let dir = FileManager.default.urls( for: .libraryDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                try "".write(to: path_file_name, atomically: true, encoding: String.Encoding.utf8)
            } catch let error{
                print("DEBUG_PRINT: refreshDocument: \(error.localizedDescription)")
            }
        }
    }
    // Libraryフォルダのファイルにデータを保存（末尾に追記）
    static func writeDocument(dataArray : [String], fileName: String) {
        if let dir = FileManager.default.urls( for: .libraryDirectory, in: .userDomainMask ).first {
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
    
    // Libraryフォルダのファイルにデータを保存（末尾に追記）
    static func writeDocument(dataArrayList : [[String]], fileName: String) {
        if let dir = FileManager.default.urls( for: .libraryDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                for  textArray in dataArrayList {
                    for text in textArray {
                        try text.appendLineToURL(fileURL: path_file_name as URL)
                    }
                }
            } catch let error{
                print("DEBUG_PRINT: writeDocument: \(error.localizedDescription)")
            }
        }
    }

    // Libraryフォルダのファイルにデータを保存（全件洗い替え）
    static func writeCardDocument(cardDataArray: Array<[String:Any]>, fileName: String) {
        var jsonStrArray = Array<Any>()
        for card in cardDataArray {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: card, options: [])
                let jsonStr = String(bytes: jsonData, encoding: .utf8)!
                jsonStrArray.append(jsonStr)
            } catch let error {
                print(error)
            }
        }
        
        if let dir = FileManager.default.urls( for: .libraryDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                let jsonArrayData = try JSONSerialization.data(withJSONObject: jsonStrArray, options: [])
                let jsonArrayStr = String(bytes: jsonArrayData, encoding: .utf8)!
                try jsonArrayStr.write(to: path_file_name, atomically: true, encoding: String.Encoding.utf8)
            } catch let error{
                print("DEBUG_PRINT: writeCardDocument: \(error.localizedDescription)")
            }
        }
    }
    // LibraryフォルダからString配列（¥n区切り）を読み込み
    static func readDocument(fileName: String) -> [String] {
        if let dir = FileManager.default.urls( for: .libraryDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                let contents = try String(contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                if !contents.isEmpty {
                    let words = contents.split(separator: "\n")
                    return words.map(String.init)
                }
            } catch let error{
                print("DEBUG_PRINT: readDocument: \(error.localizedDescription)")
            }
        }
        return []
    }
    
    // DocumentフォルダのimportファイルからString配列（任意の区切り文字）を読み込み
    static func readImportDocument(fileName: String, separator: Character) -> [String] {
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                let contents = try String(contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                if !contents.isEmpty {
                    let data = contents.split(separator: separator)
                    return data.map(String.init)
                }
            } catch let error{
                print("DEBUG_PRINT: readImportDocument: \(error.localizedDescription)")
            }
        }
        return []
    }
    
    // Libraryフォルダからjsonデータ（cardファイル）を読み込み
    static func readCardDocument(fileName: String) -> [CardData] {
        var cardDataArray: [CardData] = []
        
        if let dir = FileManager.default.urls( for: .libraryDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( fileName )
            do {
                let jsondata = try? Data(contentsOf: path_file_name)
                //-- 配列データに変換して
                if jsondata != nil && jsondata?.hashValue != 0 {
                let jsonArray = (try! JSONSerialization.jsonObject(with: jsondata!, options: [])) as! NSArray
                for jsonItem in jsonArray {
                    let jsonData: Data =  (jsonItem as AnyObject).data(using: String.Encoding.utf8.rawValue)!
                    // パースする
                    let card = try JSONSerialization.jsonObject(with: jsonData)  as! [String : AnyObject]
                    let cardData = CardData(valueDictionary: card)
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

    // 形態素分析
    static func morphologicalAnalysis(inputData: [String : Any]) -> [String]{
        var orgStr = inputData["text"] as! String
        if inputData["author"] as? String != nil {
            let orgStr2 = inputData["author"] as! String
            orgStr = orgStr + "\n" + orgStr2
        }
        
        var dataArray = Files.readDocument(fileName: Files.word_file)
        
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"), options: 0)
        tagger.string = orgStr
        tagger.enumerateTags(in: NSRange(location: 0, length: orgStr.count),
                             scheme: NSLinguisticTagScheme.tokenType,
                             options: [.omitWhitespace]) { tag, tokenRange, sentenceRange, stop in
                                // １行ごとに文字列を抜き出す
                                let subString = (orgStr as NSString).substring(with: tokenRange)
                                var lineIndex = 1
                                subString.enumerateLines{
                                    line, stop in
                                    let adjustedLine = line.components(separatedBy: Files.excludes).joined()
                                    if !adjustedLine.isEmpty {
                                        // 検索ワードリストに追加
                                        dataArray.append(adjustedLine)
                                        lineIndex += 1
                                    }
                                }
        }
        // アルファベット順で並び替え（別にしなくてもいい）
        let sortedDataArray = dataArray.sorted { $0 < $1 }
        // 重複削除
        let orderedSet:NSOrderedSet = NSOrderedSet(array: sortedDataArray)
        let strArray2 = orderedSet.array as! [String]
        
        return strArray2
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
        let characters = self.map { String($0) } // String -> [String]
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
