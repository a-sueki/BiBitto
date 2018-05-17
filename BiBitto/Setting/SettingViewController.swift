//
//  SettingViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseAuth
import SVProgressHUD
import StoreKit

class SettingViewController: FormViewController {
    
    var inputData = [String : Any]()
    let productIdentifiers = ["productIdentifier1"]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: SettingViewController viewDidLoad start")
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))
        
        print("DEBUG_PRINT: SettingViewController viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: SettingViewController viewWillAppear start")
        
        // バックアップの利用はログイン時のみに制限
        let backupButton: ButtonRow = form.rowBy(tag: "Backup")!
        if Auth.auth().currentUser == nil {
            backupButton.disabled = true
            backupButton.cell.backgroundColor = .lightGray
            backupButton.reload()
        }else{
            backupButton.disabled = false
            backupButton.cell.backgroundColor = .white
            backupButton.presentationMode = .segueName(segueName: "BackupViewControllerSegue", onDismiss: nil)
            backupButton.reload()
        }

        print("DEBUG_PRINT: SettingViewController viewWillAppear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeForm(){
        print("DEBUG_PRINT: SettingViewController initializeForm start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        // フォーム
        form +++
            Section("通知")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "通知"
                row.presentationMode = .segueName(segueName: "NotificationViewControllerSegue", onDismiss: nil)
            }

            +++ Section("アカウント")
            <<< ButtonRow("Account") { (row: ButtonRow) -> Void in
                row.title = "アカウント"
                row.presentationMode = .segueName(segueName: "AccountControllerSegue", onDismiss: nil)
            }
            
            +++ Section(header:"アップグレード", footer:"アップグレード後は「広告非表示」、「登録件数が無制限」でご利用いただけます。課金は1度だけです。" )
            <<< ButtonRow("Upgrade") { (row: ButtonRow) -> Void in
                row.title = "100円でアップグレードする"
            }.onCellSelection { [weak self] (cell, row) in
                    self?.upgrade()
            }

        
            +++ Section(header:"データ管理", footer:"オンラインバックアップの利用にはログインしている必要があります。" )
            <<< ButtonRow("ImportData") { (row: ButtonRow) -> Void in
                row.title = "ファイルから一括取込"
                row.presentationMode = .segueName(segueName: "ImportDataViewControllerSegue", onDismiss: nil)
            }
            <<< ButtonRow("Backup") { (row: ButtonRow) -> Void in
                row.title = "バックアップ"
            }
            <<< ButtonRow("category") { (row: ButtonRow) -> Void in
                row.title = "カテゴリーを編集する"
                row.presentationMode = .segueName(segueName: "CategoryControllerSegue", onDismiss: nil)
        }

        print("DEBUG_PRINT: SettingViewController initializeForm end")
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    @IBAction func upgrade() {
        print("DEBUG_PRINT: SettingViewController save start")
        
        purchase(productIdentifier: productIdentifiers[0])
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        print("DEBUG_PRINT: SettingViewController save end")
    }
    
    ///課金開始
    private func purchase(productIdentifier: String) {
        print("DEBUG_PRINT: SettingViewController purchase start")
        //デリゲード設定
        PurchaseManager.shared.delegate = self
        
        //プロダクト情報を取得
        ProductManager.request(productIdentifier: productIdentifier,
                               completion: {[weak self]  (product: SKProduct?, error: Error?) -> Void in
                                guard error == nil, let product = product else {
                                    print("DEBUG_PRINT: SettingViewController purchase error:::\(String(describing: error))")
                                    self?.purchaseManager(PurchaseManager.shared, didFailTransactionWithError: error)
                                    return
                                }
                                
                                //課金処理開始
                                PurchaseManager.shared.purchase(product: product)
        })
 
        print("DEBUG_PRINT: SettingViewController purchase end")
    }
    
    /// リストア開始
    private func startRestore() {
        print("DEBUG_PRINT: SettingViewController startRestore start")

        //デリゲード設定
        PurchaseManager.shared.delegate = self
        
        //リストア開始
        PurchaseManager.shared.restore()
        print("DEBUG_PRINT: SettingViewController startRestore end")
    }
    
}


class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}

// MARK: - PurchaseManager Delegate
extension SettingViewController: PurchaseManagerDelegate {
    func purchaseManager(_ purchaseManager: PurchaseManager, didFinishTransaction transaction: SKPaymentTransaction, decisionHandler: (Bool) -> Void) {
        //課金終了時に呼び出される
        //TODO: コンテンツ解放処理
        UserDefaults.standard.set(true, forKey:DefaultString.BillingUserFlag)
         
         
         
         
        let ac = UIAlertController(title: "支払い完了", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
        
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManager, didFinishUntreatedTransaction transaction: SKPaymentTransaction, decisionHandler: (Bool) -> Void) {
        //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
        //TODO: コンテンツ解放処理
         UserDefaults.standard.set(true, forKey:DefaultString.BillingUserFlag)

         
         
         
         
        let ac = UIAlertController(title: "purchase finish!(Untreated.)", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
        
        
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManager, didFailTransactionWithError error: Error?) {
        //課金失敗時に呼び出される
        //TODO: errorを使ってアラート表示

         
         
         
         
        let ac = UIAlertController(title: "エラーが発生しました（まだ課金されていません）", message: error?.localizedDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager) {
        //リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
        //TODO: インジケータなどを表示していたら非表示に
        UserDefaults.standard.set(true, forKey:DefaultString.BillingUserFlag)

         
         
         
         
        let ac = UIAlertController(title: "restore finish!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager) {
        //承認待ち状態時に呼び出される(ファミリー共有)
        //TODO: インジケータなどを表示していたら非表示に
        print("承認待ち...")
         
         
         
         
        let ac = UIAlertController(title: "purcase defferd.", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
