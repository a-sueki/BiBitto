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
            
        +++ Section(header:"ファイルから一括取込", footer:"取込対象のファイル（.csv形式）はご使用のiOSデバイスの「ファイル > BiBitto」内に格納してください")
            // importデータのファイル名を取得
            <<< NameRow("filename") {
                $0.title = "ファイル名"
                $0.placeholder = "TestCSV"
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
                $0.value = .Indention1
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "一括取込の実行"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: \(error)のため処理は行いません")
                    }else{
                        self?.importFile()
                    }
            }

            +++ Section("※チュートリアル※")
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
        
        print("tapped!!")
        
        /*
         
         
         // ファイルを読み込み、配列に保存

         
         
         
         // inputDataに必要な情報を取得しておく
         let time = NSDate.timeIntervalSinceReferenceDate
         importData["updateAt"] = String(time)
         importData["createAt"] = String(time)
         
         // ログインしている場合、firebaseにinsert
         if let uid = Auth.auth().currentUser?.uid {
         // 辞書を作成
         let ref = Database.database().reference()
         let key = ref.child(Paths.CardPath).childByAutoId().key
         importData["id"] = key
         ref.child(Paths.CardPath).child(uid).child(key).setValue(importData)
         print("DEBUG_PRINT: AddViewController FB inserted!")
         }else{
         inputData["id"] = DummyString.Key
         }
         
         // No付与
         inputData["no"] = cardDataArray.count + 1
         
         // カード追加
         let cardData = CardData(valueDictionary: inputData as [String : AnyObject])
         cardDataArray.append(cardData)
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
         // ファイル内テキスト全件クリア
         Files.refreshDocument(fileName: Files.card_file)
         // ファイル書き込み（全件洗い替え）
         Files.writeCardDocument(cardDataArray: outputDataArray ,fileName: Files.card_file)
         
         // 検索用ワードをファイル書き込み（追記）
         morphologicalAnalysis(inputData: inputData)
         
         // 成功ポップアップ
         SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
         
         // 一覧へのデータ渡し
         let nav = self.navigationController!
         //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
         let listViewController = nav.viewControllers[nav.viewControllers.count-2] as! ListViewController
         listViewController.cardDataArray = sortedCardDataArray
         // 前画面に戻る
         self.navigationController?.popViewController(animated: false)
         
         print("DEBUG_PRINT: SettingViewController importFile end")
         }
         */
        
        
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
        case Indention1 = "改行（¥n）"
        case Indention2 = "改行その２（\n）"
        case Comma = "コンマ（,）"
        
        var description : String { return rawValue }
        
        static let allValues = [Indention1, Indention2, Comma]
    }

}
