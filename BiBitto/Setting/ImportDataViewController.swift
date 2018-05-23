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
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: ImportDataViewController viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: ImportDataViewController viewWillAppear start")
        
        // バックアップの利用はログイン時のみに制限
        let autoSaveSwitch: SwitchRow = form.rowBy(tag: "autoSave")!
        if Auth.auth().currentUser == nil {
            autoSaveSwitch.value = false
            autoSaveSwitch.disabled = true
            autoSaveSwitch.cell.backgroundColor = .lightGray
            autoSaveSwitch.reload()
        }else{
            autoSaveSwitch.disabled = false
            autoSaveSwitch.cell.backgroundColor = .white
            autoSaveSwitch.reload()
        }
        // カテゴリのリフレッシュ
        let categoryLabel:PushRow<String> = form.rowBy(tag: "category")!
        //categoryLabel.value = UserDefaults.standard.string(forKey: DefaultString.Category1) ?? Category.continents.first
        categoryLabel.reload()
        
        print("DEBUG_PRINT: ImportDataViewController viewWillAppear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initializeForm(){
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
            Section(header:"ファイルから一括取込", footer:"取込対象のファイル（.txt形式）はご使用のiOSデバイスの「ファイル > BiBitto」内に格納してください")
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
            
            // カテゴリーを選択させる
            <<< PushRow<String>("category") {
                $0.title = "カテゴリー"
                $0.options = Category.continents
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Category1) ?? Category.continents.first
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })

            
            <<< SwitchRow("autoSave"){
                $0.title = "バックアップも更新する"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.AutoBackup)
            }
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "一括取込の実行"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: \(error)のため処理は行いません")
                    }else{
                        self?.importFile()
                    }
            }
            
            +++ Section("チュートリアル")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "ファイル取込方法を確認する"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.jumpToHowtousePage()
        }
        
        print("DEBUG_PRINT: ImportDataViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    @IBAction func importFile(){
        print("DEBUG_PRINT: ImportDataViewController importFile start")
        
        for (key,value) in form.values() {
            if key == "category" {
                switch value as! String{
                case Category.continents[0] : self.inputData["category"] = DefaultString.Category1
                case Category.continents[1] : self.inputData["category"] = DefaultString.Category2
                case Category.continents[2] : self.inputData["category"] = DefaultString.Category3
                case Category.continents[3] : self.inputData["category"] = DefaultString.Category4
                case Category.continents[4] : self.inputData["category"] = DefaultString.Category5
                default: self.inputData["\(key)"] = value
                }
            }else{
                self.inputData["\(key)"] = value
            }
        }

        if Auth.auth().currentUser == nil, self.inputData["autoSave"] as! Bool == true {
            SVProgressHUD.showError(withStatus: Alert.pleaseloginAlartTitle)
            return
        }
        var totalCardCount = 0
        
        // 追加の場合
        if self.inputData["LoadingType"] as! LoadingType == LoadingType.Add {
            // cardファイルからデータ取得
            self.cardDataArray = CardFileIntermediary.getList()
            totalCardCount = self.cardDataArray.count
        }else{
            // ファイル内テキスト全件クリア
            Files.refreshDocument(fileName: Files.card_file)
            Files.refreshDocument(fileName: Files.word_file)
        }
        
        // 区切り文字
        if inputData["Delimiter"] as! Delimiter == Delimiter.Indention {
            // 改行
            self.importDataArray = Files.readImportDocument(fileName: self.inputData["FileName"] as! String, separator: "\n")
            totalCardCount = totalCardCount + self.importDataArray.count
        } else {
            // コンマ
            self.importDataArray = Files.readImportDocument(fileName: self.inputData["FileName"] as! String, separator: ",")
            totalCardCount = totalCardCount + self.importDataArray.count
        }

        print("カード合計件数：\(totalCardCount)、一括登録件数：\(self.importDataArray.count)")
        
        if totalCardCount > 99 {
            if UserDefaults.standard.bool(forKey: DefaultString.BillingUserFlag){
                //,(Auth.auth().currentUser?.uid) != nil {
                SVProgressHUD.show(withStatus: "\(self.importDataArray.count)件のデータを登録中...")
            }else{
                SVProgressHUD.showError(withStatus: Alert.limited)
                return
            }
        }
        
        // 遅延実行
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter( deadline: dispatchTime) {
            // Card形式に生成
            for data in self.importDataArray {
                let time = NSDate.timeIntervalSinceReferenceDate
                self.importData["updateAt"] = String(time)
                self.importData["createAt"] = String(time)
                self.importData["text"] = data
                self.importData["category"] = self.inputData["category"] as! String
                // No付与
                self.importData["no"] = self.cardDataArray.count + 1
                // カード追加
                let cardData = CardData(valueDictionary: self.importData as [String : AnyObject])
                self.cardDataArray.append(cardData)
                
                // 検索用ワードをファイル書き込み（追記）
                let wordArray = Files.morphologicalAnalysis(inputData: self.importData)
                self.wordArrayList.append(wordArray)
            }
            // Noで並び替え
            self.cardDataArray = self.cardDataArray.sorted(by: {$0.no < $1.no})
            // No洗い替え
            var counter = 1
            for card in self.cardDataArray {
                card.no = counter
                counter = counter + 1
            }
            
            // ファイル書き込み用カード配列作成
            self.outputDataArray = CardUtils.cardToDictionary(cardDataArray: self.cardDataArray)
            // ファイル書き込み
            Files.writeCardDocument(cardDataArray: self.outputDataArray ,fileName: Files.card_file)
            Files.writeDocument(dataArrayList: self.wordArrayList ,fileName: Files.word_file)
            // 他画面での参照用配列をアップデート
            CardFileIntermediary.setList(list: self.cardDataArray)
            
            // ログインしている場合、firebaseStorageにupdate
            if let uid = Auth.auth().currentUser?.uid, self.inputData["autoSave"] as! Bool == true {
                // ストレージに保存
                StorageProcessing.storageUpload(fileType: Files.card_file, key: uid)
                StorageProcessing.storageUpload(fileType: Files.word_file, key: uid)
                print("DEBUG_PRINT: ImportDataViewController FB Storage uploaded!")
            }
            // 全てのモーダルを閉じる
            SVProgressHUD.dismiss()
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            // Home画面に戻る（選択済みにする）
            let nav = self.navigationController!
            nav.viewControllers[nav.viewControllers.count-2].tabBarController?.selectedIndex = 1
            // 成功ポップアップ
            SVProgressHUD.showSuccess(withStatus: Alert.successImportTitle)
        }
        
        print("DEBUG_PRINT: ImportDataViewController importFile end")
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
        case Update = "更新（全件削除→取込）"
        
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
