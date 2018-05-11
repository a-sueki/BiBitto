//
//  CategoryViewController.swift
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

class CategoryViewController: FormViewController {

    var inputData = [String : Any]()
    
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
        print("DEBUG_PRINT: CategoryViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        form +++
            MultivaluedSection(multivaluedOptions: .Reorder,
                           header: "Reordering Field Rows",
                           footer: "")
            <<< NameRow {
                $0.value = Category.continents[0]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "orange")
            }
            <<< NameRow {
                $0.value = Category.continents[1]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "pink")
            }
            <<< NameRow {
                $0.value = Category.continents[2]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "green")
            }
            <<< NameRow {
                $0.value = Category.continents[3]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "blue")
            }
            <<< NameRow {
                $0.value = Category.continents[4]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "purple")
            }

            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "保存する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        print("DEBUG_PRINT: 保存 \(error)のため処理は行いません")
                    }else{
                        self?.editCategory()
                    }
        }
        print("DEBUG_PRINT: CategoryViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        if row.section === form[0] {
            print("Single Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRow()?.baseValue ?? "No row selected")")
        }
    }
    
    @IBAction func editCategory(){
        print("DEBUG_PRINT: CategoryViewController editCategory start")
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
            }
        }        
        // 成功ポップアップ
        SVProgressHUD.showError(withStatus: Alert.successSendTitle)
        // 前画面に戻る
        self.navigationController?.popViewController(animated: false)
        
        print("DEBUG_PRINT: CategoryViewController editCategory end")
    }
}


