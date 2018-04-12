//
//  ImportDataViewController.swift
//  BiBitto
//
//  Created by admin on 2018/04/04.
//  Copyright © 2018年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseAuth
import SVProgressHUD

class ImportDataViewController: FormViewController {
    
    var inputData = [String : Any]()
    var importData = [String : Any]()
    var importDataArray = [String]()
    var cardDataArray: [CardData] = []
    var cardData: CardData?
    var outputDataArray = Array<[String : Any]>()
    var wordArrayList = Array<[String]>()


    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: ImportDataViewController viewDidLoad start")
        
        initializeForm(lastSavingDateTime: "2018-04-04 13:47")
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: ImportDataViewController viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func initializeForm(lastSavingDateTime: String){
        print("DEBUG_PRINT: ImportDataViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section(header:"復元（最終保存日時:\(lastSavingDateTime)）", footer:"オンラインバックアップの利用にはアカウント作成が必要です。" )
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "オンラインバックアップから復元"
                // ログインしてない場合、非活性にして表示
                row.disabled = .function([""], { form -> Bool in
                        if Auth.auth().currentUser != nil {
                            return false
                        }else{
                            return true
                        }
                    })
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        print("DEBUG_PRINT: ImportDataViewController. restore \(error)のため処理は行いません")
                    }else{
                        if Auth.auth().currentUser == nil {
                            SVProgressHUD.showError(withStatus: Alert.loginAlartTitle)
                        }else{
                            self?.restore()
                        }
                    }
            }
            
        +++ Section(header:"ファイルから一括取込", footer:"取込対象のファイル（.txt形式）はご使用のiOSデバイスの「ファイル > BiBitto」内に格納してください")
            // importデータのファイル名を取得
            <<< NameRow("FileName") {
                $0.title = "ファイル名"
                $0.placeholder = "テキスト.txt"
                $0.value = nil
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnBlur
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
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

            // 追加か、全件洗い替えか
            <<< PushRow<LoadingType>("LoadingType") {
                $0.title = "追加/更新"
                $0.options = LoadingType.allValues
                $0.value = .Add
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })
            
            // 区切り文字を選択させるLoading format
            <<< PushRow<Delimiter>("Delimiter") {
                $0.title = "区切り文字"
                $0.options = Delimiter.allValues
                $0.value = .Indention
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "ファイル取込方法を確認する"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.jumpToHowtousePage()
            }           <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "一括取込の実行"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: \(error)のため処理は行いません")
                    }else{
                        self?.importFile()
                    }
            }

        print("DEBUG_PRINT: ImportDataViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    @IBAction func restore() {
        print("DEBUG_PRINT: ImportDataViewController restore start")
        
        var cardDataArray: [CardData] = []
        // Firebaseからデータを取得し、UserDefaultにセット
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child(Paths.CardPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: ImportDataViewController restore .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let cardData = CardData(snapshot: snapshot)
                    cardDataArray.append(cardData)
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successRestoreTitle)
        
        print("DEBUG_PRINT: ImportDataViewController restore end")
    }

    @IBAction func importFile(){
        print("DEBUG_PRINT: ImportDataViewController importFile start")

        for (key,value) in form.values() {
            if value != nil {
                inputData["\(key)"] = value
            }
        }
        
        var totalCardCount = 0
        
        // 追加の場合
        if inputData["LoadingType"] as! LoadingType == LoadingType.Add {
            // cardファイルからデータ取得
            self.cardDataArray = Files.readCardDocument(fileName: Files.card_file)
            totalCardCount = self.cardDataArray.count
        }else{
            // ファイル内テキスト全件クリア
            Files.refreshDocument(fileName: Files.card_file)
            Files.refreshDocument(fileName: Files.word_file)
        }
        
        // ファイル読み込み
        if inputData["Delimiter"] as! Delimiter == Delimiter.Indention {
            importDataArray = Files.readImportDocument(fileName: inputData["FileName"] as! String, separator: "\n")
            totalCardCount = totalCardCount + importDataArray.count
        } else {
            //TODO: 区切り文字（任意）
        }
        print("カード合計件数：\(totalCardCount)、一括登録件数：\(importDataArray.count)")

        if totalCardCount > 99 {
            if (Auth.auth().currentUser?.uid) != nil {
                SVProgressHUD.show(withStatus: "\(importDataArray)件のデータを登録中...")
            }else{
                SVProgressHUD.showError(withStatus: Alert.limited)
                return
            }
        }
        
        // Card形式に生成
        for data in importDataArray {
            let time = NSDate.timeIntervalSinceReferenceDate
            importData["updateAt"] = String(time)
            importData["createAt"] = String(time)
            importData["text"] = data
            importData["category"] = Category.continents.first
            
            // ログインしている場合、firebaseにinsert
            if let uid = Auth.auth().currentUser?.uid {
                // 辞書を作成
                let ref = Database.database().reference()
                let key = ref.child(Paths.CardPath).childByAutoId().key
                importData["id"] = key
                ref.child(Paths.CardPath).child(uid).child(key).setValue(importData)
                print("DEBUG_PRINT: ImportDataViewController FB inserted!")
            }else{
                importData["id"] = DummyString.Key
            }
            // No付与
            importData["no"] = cardDataArray.count + 1
            // カード追加
            let cardData = CardData(valueDictionary: importData as [String : AnyObject])
            cardDataArray.append(cardData)
            
            // 検索用ワードをファイル書き込み（追記）
            let wordArray = morphologicalAnalysis(inputData: importData)
            wordArrayList.append(wordArray)
        }
        
        // 作成日で並び替え
        let sortedCardDataArray = cardDataArray.sorted(by: {
            $1.createAt.compare($0.createAt as Date) == ComparisonResult.orderedDescending
        })
        // No洗い替え
        var counter = 1
        for card in sortedCardDataArray {
            card.no = counter
            counter = counter + 1
        }

        // ファイル書き込み用カード配列作成
        outputDataArray = CardUtils.cardToDictionary(cardDataArray: sortedCardDataArray)
        // ファイル書き込み
        Files.writeCardDocument(cardDataArray: outputDataArray ,fileName: Files.card_file)
        Files.writeDocument(dataArrayList: wordArrayList ,fileName: Files.word_file)

        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        // 前画面に戻る
        self.navigationController?.popViewController(animated: false)
        
        print("DEBUG_PRINT: ImportDataViewController importFile end")
    }
    
    // 形態素分析
    func morphologicalAnalysis(inputData: [String : Any]) -> [String]{
        print("DEBUG_PRINT: ImportDataViewController morphologicalAnalysis start")
        
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

    @IBAction func jumpToHowtousePage() {
        print("DEBUG_PRINT: ImportDataViewController jumpToHowtousePage start")
        
        guard let url = URL(string: URLs.HowToUseLink) else {
            return //be safe
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        print("DEBUG_PRINT: ImportDataViewController jumpToHowtousePage end")
    }
    
    enum LoadingType : String, CustomStringConvertible {
        case Add = "追加"
        case Update = "更新（全件削除→ファイルデータを取込）"
        
        var description : String { return rawValue }
        
        static let allValues = [Add, Update]
    }
/*
    enum LoadingFileFormat : String, CustomStringConvertible {
        case Csv = ".csvファイル"
        case Txt = ".txtファイル" // 文字コードを指定させる必要あり
        
        var description : String { return rawValue }
        
        static let allValues = [Csv, Txt]
    }
    */
    enum Delimiter : String, CustomStringConvertible {
        case Indention = "改行"
        case Comma = "コンマ"
        
        var description : String { return rawValue }
        
        static let allValues = [Indention, Comma]
    }

}
