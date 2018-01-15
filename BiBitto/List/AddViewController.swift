//
//  AddViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Presentr
import Eureka
import Firebase
import FirebaseAuth

class AddViewController: FormViewController {
        
    var inputData = [String : Any]()
    var cardDataArray = [CardData]()
    var cardData: CardData?
    var charCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeForm(){
        print("DEBUG_PRINT: AddViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section("ビビッとくる言葉")
            <<< TextAreaRow("text") {
                $0.placeholder = "ビビッときたフレーズ"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged { cell, row in
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
            
            +++ Section()
            <<< SwitchRow("option") {
                $0.title = "もっと細かく入力する"
                $0.value = false
            }
            +++ Section("オプション"){
                $0.hidden = .function(["option"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "option")
                    return row.value ?? false == false
                })
            }
            <<< TextRow("title").cellSetup {cell, row in
                cell.textField.placeholder = "タイトル"
            }
            <<< TextRow("author").cellSetup { cell, row in
                cell.textField.placeholder = "出典/著者"
        }
                
        form +++ SelectableSection<ImageCheckRow<String>>() { section in
            section.header = HeaderFooterView(title: "カテゴリー")
        }
        
        for option in Category.continents {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
            }
        }
        
        
        form  +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "追加する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: 追加 \(error)のため処理は行いません")
                    }else{
                        self?.addCard()
                    }
            }
            
            +++ Section("編集")
            <<< ButtonRow("category") { (row: ButtonRow) -> Void in
                row.title = "カテゴリーを編集する"
                row.presentationMode = .segueName(segueName: "CategoryControllerSegue", onDismiss: nil)
        }
        
        print("DEBUG_PRINT: AddViewController initializeForm end")
    }
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    @IBAction func addCard(){
        print("DEBUG_PRINT: AddViewController addCard start")
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                switch key {
                case Category.continents[0] : self.inputData["category"] = itemValue
                case Category.continents[1] : self.inputData["category"] = itemValue
                case Category.continents[2] : self.inputData["category"] = itemValue
                case Category.continents[3] : self.inputData["category"] = itemValue
                case Category.continents[4] : self.inputData["category"] = itemValue
                default: self.inputData["\(key)"] = itemValue
                }
            }
        }

        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        // 辞書を作成
        let ref = Database.database().reference()
        // Noを取得
        inputData["no"] = String(format: "%04d", cardDataArray.count + 1)

        //Firebaseに保存
        if let data = cardData {
            print("DEBUG_PRINT: AddViewController addCard update")
            // 更新しないデータを引き継ぎ
            inputData["createAt"] = String(data.createAt.timeIntervalSinceReferenceDate)
            inputData["updateAt"] = String(time)
        }else{
            print("DEBUG_PRINT: AddViewController addCard insert")
            let key = ref.child(Paths.CardPath).childByAutoId().key
            inputData["updateAt"] = String(time)
            inputData["createAt"] = String(time)
            // insert
            if let uid = Auth.auth().currentUser?.uid {
                ref.child(Paths.CardPath).child(uid).child(key).setValue(inputData)
            }
        }

        // ファイル書き込み（追記）
        Files.writeCardDocument(card: inputData ,fileName: Files.card_file)
        
        // 登録された文章に含まれる単語を検索用に、data.txtに追記
        morphologicalAnalysis(inputData: inputData)
      
        // 成功ポップアップ
        self.present(Alert.setAlertController(title: Alert.successSaveTitle, message: nil), animated: true, completion: {() -> Void in
            DispatchQueue.global(qos: .default).async {
                // サブスレッド(バックグラウンド)で実行する方を書く
                DispatchQueue.main.async {
                    // Main Threadで実行する
                    self.navigationController?.popViewController(animated: false)
                }
            }
        })

        print("DEBUG_PRINT: AddViewController addCard end")
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        if row.section === form[3] {
            print("Single Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRow()?.baseValue ?? "No row selected")")
        }
    }
    
    // 形態素分析
    func morphologicalAnalysis(inputData: [String : Any]) {
        print("DEBUG_PRINT: AddViewController morphologicalAnalysis start")
        
        var orgStr = inputData["text"] as! String
        if inputData["title"] as? String != nil {
            let orgStr1 = inputData["title"] as! String
            orgStr = orgStr + "\n" + orgStr1
        }
        if inputData["author"] as? String != nil {
            let orgStr2 = inputData["author"] as! String
            orgStr = orgStr + "\n" + orgStr2
        }

        var dataArray = Files.readDocument(fileName: Files.word_file)
        
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"), options: 0)
        tagger.string = orgStr
        tagger.enumerateTags(in: NSRange(location: 0, length: orgStr.characters.count),
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
        
        // ファイル内テキスト全件クリア
        Files.refreshDocument(fileName: Files.word_file)
        // ファイル書き込み
        Files.writeDocument(dataArray: strArray2,fileName: Files.word_file)
     
        print("DEBUG_PRINT: AddViewController morphologicalAnalysis end")
    }
}

public final class ImageCheckRow<T: Equatable>: Row<ImageCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class ImageCheckCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Image for selected state
    lazy public var trueImage: UIImage = {
        return UIImage(named: "selected")!
    }()
    
    /// Image for unselected state
    lazy public var falseImage: UIImage = {
        return UIImage(named: "unselected")!
    }()
    
    public override func update() {
        super.update()
        checkImageView?.image = row.value != nil ? trueImage : falseImage
        checkImageView?.sizeToFit()
    }
    
    /// Image view to render images. If `accessoryType` is set to `checkmark`
    /// will create a new `UIImageView` and set it as `accessoryView`.
    /// Otherwise returns `self.imageView`.
    open var checkImageView: UIImageView? {
        guard accessoryType == .checkmark else {
            return self.imageView
        }
        
        guard let accessoryView = accessoryView else {
            let imageView = UIImageView()
            self.accessoryView = imageView
            return imageView
        }
        
        return accessoryView as? UIImageView
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .none
    }
    
    public override func didSelect() {
        row.reload()
        row.select()
        row.deselect()
    }
    
}


