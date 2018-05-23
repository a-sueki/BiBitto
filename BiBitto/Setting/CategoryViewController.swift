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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: CategoryViewController viewWillAppear start")
        
        let categorySection: Section = form.allSections[0]
        categorySection.reload()
        
        print("DEBUG_PRINT: CategoryViewController viewWillAppear end")
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
            <<< NameRow("category1") {
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Category1) ?? "MIND"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "orange")
                    cell.imageView?.alpha = 0.6
            }
            <<< NameRow("category2") {
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Category2) ?? "LEADERSHIP"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "pink")
                    cell.imageView?.alpha = 0.6
            }
            <<< NameRow("category3") {
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Category3) ?? "VISION"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "green")
                    cell.imageView?.alpha = 0.6
            }
            <<< NameRow("category4") {
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Category4) ?? "WISDOM"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "blue")
                    cell.imageView?.alpha = 0.6
            }
            <<< NameRow("category5") {
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Category5) ?? "FELLOW"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "purple")
                    cell.imageView?.alpha = 0.6
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
    
/*    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        if row.section === form[0] {
            print("Single Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRow()?.baseValue ?? "No row selected")")
        }
    }
 */
    
    @IBAction func editCategory(){
        print("DEBUG_PRINT: CategoryViewController editCategory start")
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
            }
        }
        
        UserDefaults.standard.set(self.inputData["category1"] ,forKey: DefaultString.Category1)
        UserDefaults.standard.set(self.inputData["category2"] ,forKey: DefaultString.Category2)
        UserDefaults.standard.set(self.inputData["category3"] ,forKey: DefaultString.Category3)
        UserDefaults.standard.set(self.inputData["category4"] ,forKey: DefaultString.Category4)
        UserDefaults.standard.set(self.inputData["category5"] ,forKey: DefaultString.Category5)

        // 全てのモーダルを閉じる
        SVProgressHUD.dismiss()
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 成功ポップアップ
        SVProgressHUD.showSuccess(withStatus: Alert.successSaveTitle)
        
        print("DEBUG_PRINT: CategoryViewController editCategory end")
    }
}


