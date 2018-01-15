//
//  FirstViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import Firebase
import FirebaseAuth

class ListViewController: TabmanViewController, PageboyViewControllerDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var viewControllers = [UIViewController]()
    var cardDataArray: [CardData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: ListViewController viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)

        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.dataSource = self
        
        // configure the bar
        self.bar.items = [Item(title: "Page 1"),
                          Item(title: "Page 2")]
        
        // search button
        let rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchButtonTapped))
        self.navigationItem.setRightBarButtonItems([rightSearchBarButtonItem], animated: true)
        // add button
        let leftSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.setLeftBarButtonItems([leftSearchBarButtonItem], animated: true)

        // 潜り込み防止策
        tableView.contentInsetAdjustmentBehavior = .automatic
        let edgeInsets = UIEdgeInsets(top: 42, left: 0, bottom: 0, right: 0)
        tableView.contentInset = edgeInsets
        tableView.scrollIndicatorInsets = edgeInsets
        
        print("DEBUG_PRINT: ListViewController viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: ListViewController viewWillAppear start")
        
        self.cardDataArray = Files.readCardDocument(fileName: Files.card_file)
        // tableViewを再表示する
        DispatchQueue.main.async {
            print("DEBUG_PRINT: ListViewController [DispatchQueue.main.async]")
            self.tableView.reloadData()
        }

        /*        cardDataArray.removeAll()
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child(Paths.CardPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: ListViewController .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    for childSnap in snapshot.children {
                        let cardData = CardData(snapshot: childSnap as! DataSnapshot)
                        self.cardDataArray.append(cardData)
                    }
                }
                // tableViewを再表示する
                DispatchQueue.main.async {
                    print("DEBUG_PRINT: ListViewController [DispatchQueue.main.async]")
                    self.tableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
 */
        
        
        print("DEBUG_PRINT: ListViewController viewWillAppear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func searchButtonTapped() {
        print("DEBUG_PRINT: ListViewController searchButtonTapped start")
        
        let searchViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(searchViewController, animated: true)
        
        print("DEBUG_PRINT: ListViewController searchButtonTapped end")
    }
    @objc func addButtonTapped() {
        print("DEBUG_PRINT: ListViewController addButtonTapped start")
        
        let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        addViewController.cardDataArray = self.cardDataArray
        self.navigationController?.pushViewController(addViewController, animated: true)
        
        print("DEBUG_PRINT: ListViewController addButtonTapped end")
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT: ListViewController numberOfRowsInSection")
        return cardDataArray.count
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: ListViewController didSelectRowAt start")
        
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print("DEBUG_PRINT: ListViewController didSelectRowAt end")
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        print("DEBUG_PRINT: ListViewController editingStyleForRowAt")
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        print("DEBUG_PRINT: ListViewController editingStyleForRowAt ")
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    //返すセルを決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: ListViewController cellForRowAt start")
        
        //xibとカスタムクラスで作成したCellのインスタンスを作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        let noStr = String(format: "%04d", cardDataArray.count + 1)
        
        cell.setData(cardData: cardDataArray[indexPath.row], no: noStr)
        
        print("DEBUG_PRINT: ListViewController cellForRowAt end")
        return cell
    }
    
    // 左スワイプで削除ボタン表示
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: ListViewController commit editingStyle start")

        // firebaseから削除
        if editingStyle == .delete {
            if let uid = Auth.auth().currentUser?.uid, !(cardDataArray[indexPath.row].id?.isEmpty)! {
                let ref = Database.database().reference().child(Paths.CardPath).child(uid)
                ref.child(cardDataArray[indexPath.row].id!).removeValue()
            }
        }
        // リストから削除
        cardDataArray.remove(at: indexPath.row)
        // 一覧画面から削除
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        print("DEBUG_PRINT: ListViewController commit editingStyle end")
    }
}
