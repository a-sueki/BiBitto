//
//  FirstViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Pageboy
import Firebase
import FirebaseAuth

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        // search button
        let rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchButtonTapped))
        self.navigationItem.setRightBarButtonItems([rightSearchBarButtonItem], animated: true)
        // add button
        let leftSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.setLeftBarButtonItems([leftSearchBarButtonItem], animated: true)
        
        self.setScrollPosition()
        
        // カード一覧をローカルファイルから取得
        let originCardDataArray = CardFileIntermediary.getList()
        // Noで並び替え
        self.cardDataArray = originCardDataArray.sorted(by: {$0.no > $1.no})
        
        print("DEBUG_PRINT: ListViewController viewDidLoad end")
    }
    
    func setScrollPosition() {
        print("DEBUG_PRINT: ListViewController setScrollPosition start")
        
        // 潜り込み防止策
        tableView.contentInsetAdjustmentBehavior = .automatic
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.contentInset = edgeInsets
        tableView.scrollIndicatorInsets = edgeInsets

        print("DEBUG_PRINT: ListViewController setScrollPosition end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: ListViewController viewWillAppear start")

        // tableViewを再表示する
        DispatchQueue.main.async {
            print("DEBUG_PRINT: ListViewController [DispatchQueue.main.async]")
            self.tableView.reloadData()
        }
        
        print("DEBUG_PRINT: ListViewController viewWillAppear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: ListViewController viewWillDisappear start")
        
        /* Searchでの絞り込みリセット */
        // カード一覧をローカルファイルから取得
        let originCardDataArray = CardFileIntermediary.getList()
        // Noで並び替え
        self.cardDataArray = originCardDataArray.sorted(by: {$0.no > $1.no})
        
        print("DEBUG_PRINT: ListViewController viewWillDisappear end")
    }
    
    @objc func searchButtonTapped() {
        print("DEBUG_PRINT: ListViewController searchButtonTapped start")
        
        let searchViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchViewController.cardDataArray = self.cardDataArray
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
        
        // 配列からタップされたインデックスのデータを取り出す
        let selectedCardData = self.cardDataArray[indexPath.row]
        
        let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        addViewController.cardDataArray = self.cardDataArray
        addViewController.cardData = selectedCardData
        self.navigationController?.pushViewController(addViewController, animated: true)
        
        // 選択解除（ハイライトを消す）
        tableView.deselectRow(at: indexPath, animated: true)
        
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
        
        cell.setData(cardData: cardDataArray[indexPath.row])
        
        print("DEBUG_PRINT: ListViewController cellForRowAt end")
        return cell
    }
    
    // 左スワイプで削除ボタン表示
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: ListViewController commit editingStyle start")

        if editingStyle == .delete {
            //リストから削除
            cardDataArray.remove(at: indexPath.row)
            // Noで並び替え
            self.cardDataArray = self.cardDataArray.sorted(by: {$0.no < $1.no})
            // No洗い替え
            var counter = 1
            for card in self.cardDataArray {
                card.no = counter
                counter = counter + 1
            }
            // ファイル書き込み用カード配列作成
            var outputDataArray = Array<[String : Any]>()
            outputDataArray = CardUtils.cardToDictionary(cardDataArray: self.cardDataArray)
            // ファイル内テキスト全件クリア
            Files.refreshDocument(fileName: Files.card_file)
            // ファイル書き込み（全件洗い替え）
            Files.writeCardDocument(cardDataArray: outputDataArray ,fileName: Files.card_file)
            // 他画面での参照用配列をアップデート
            CardFileIntermediary.setList(list: self.cardDataArray)

        }

        // 一覧画面から削除
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        print("DEBUG_PRINT: ListViewController commit editingStyle end")
    }
}
