//
//  AddViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import SVProgressHUD
import Eureka
import Firebase
import FirebaseAuth

class AddViewController: FormViewController {
    
    var inputData = [String : Any]()
    var outputDataArray = Array<[String : Any]>()
    var cardDataArray = [CardData]()
    var cardData: CardData?
    var charCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
        self.navigationItem.leftBarButtonItem?.target = self
        self.navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
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
                if option == Category.continents.first {
                    lrow.value = option
                }else{
                    lrow.value = nil
                }
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
        inputData["updateAt"] = String(time)
        inputData["createAt"] = String(time)
        // No付与
        inputData["no"] = cardDataArray.count + 1
        // カード追加
        let cardData = CardData(valueDictionary: inputData as [String : AnyObject])
        cardDataArray.append(cardData)
        // No洗い替え
        var counter = 1
        for card in cardDataArray {
            card.no = counter 
            counter = counter + 1
        }
        // ファイル書き込み用カード配列作成
        outputDataArray = CardUtils.cardToDictionary(cardDataArray: cardDataArray)
        // ファイル内テキスト全件クリア
        Files.refreshDocument(fileName: Files.card_file)
        // ファイル書き込み（全件洗い替え）
        Files.writeCardDocument(cardDataArray: outputDataArray ,fileName: Files.card_file)
        
        // 検索用ワードをファイル書き込み（追記）
        let strArray2 = Files.morphologicalAnalysis(inputData: inputData)
        // ファイル内テキスト全件クリア
        Files.refreshDocument(fileName: Files.word_file)
        // ファイル書き込み
        Files.writeDocument(dataArray: strArray2,fileName: Files.word_file)
        // ログインしている場合、firebaseStorageにupdate
        if let uid = Auth.auth().currentUser?.uid {
            // ストレージに保存
            StorageProcessing.storageUpload(fileType: Files.card_file, key: uid)
            StorageProcessing.storageUpload(fileType: Files.word_file, key: uid)
            print("DEBUG_PRINT: AddViewController FB Storage uploaded!")
        }
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)

        //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
        let nav = self.navigationController!
        let listViewController = nav.viewControllers[nav.viewControllers.count-2] as! ListViewController
        listViewController.cardDataArray = cardDataArray
        // 前画面に戻る
        self.navigationController?.popViewController(animated: false)
        
        print("DEBUG_PRINT: AddViewController addCard end")
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        if row.section === form[3] {
            print("Single Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRow()?.baseValue ?? "No row selected")")
        }
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


