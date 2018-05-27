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
import GoogleMobileAds
import SVProgressHUD

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private var viewControllers = [UIViewController]()
    var cardDataArray: [CardData] = []
    var bannerView: GADBannerView!
    var filtered = false

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
        
        if !UserDefaults.standard.bool(forKey: DefaultString.BillingUserFlag){ // 本番用
        //if UserDefaults.standard.bool(forKey: DefaultString.BillingUserFlag){ // キャプチャ用
            // iAd広告設定
            //self.canDisplayBannerAds = true
            // In this case, we instantiate the banner with desired ad size.
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            
            bannerView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - bannerView.frame.height - (self.tabBarController?.tabBar.frame.size.height)!)
            bannerView.frame.size = CGSize(width:self.view.frame.width, height:bannerView.frame.height)
            // AdMobで発行された広告ユニットIDを設定
            bannerView.adUnitID = "ca-app-pub-5249520015075390/2816639411"
            
            // テスト用ID
            //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            
            bannerView.delegate = self
            bannerView.rootViewController = self
            let gadRequest:GADRequest = GADRequest()
            // テスト用の広告を表示する時のみ使用（申請時に削除）
            //gadRequest.testDevices = ["26a658cbdbafefa0529a98321fa5a5b1"]
            
            bannerView.load(gadRequest)
            self.view.addSubview(bannerView)
        }
        
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
        
        if filtered == true {
            // tableViewを再表示する
            self.tableView.reloadData()
        }else{
            var originCardDataArray: [CardData]! = nil
            DispatchQueue.global().async {
                // カード一覧をローカルファイルから取得
                originCardDataArray = CardFileIntermediary.getList()
            }
            // cardDataArrayを取得するまで待ちます
            Files.wait( { return originCardDataArray == nil } ) {
                // 取得しました
                print("finish!!!")
                // Noで並び替え
                self.cardDataArray = originCardDataArray.sorted(by: {$0.no > $1.no})
                // tableViewを再表示する
                self.tableView.reloadData()
            }
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
        filtered == false
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
        
        if self.cardDataArray.count > 99 {
            if UserDefaults.standard.bool(forKey: DefaultString.BillingUserFlag){
                let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
                addViewController.cardDataArray = self.cardDataArray
                self.navigationController?.pushViewController(addViewController, animated: true)
            }else{
                SVProgressHUD.showError(withStatus: Alert.limited)
            }
        }else{
            let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
            addViewController.cardDataArray = self.cardDataArray
            self.navigationController?.pushViewController(addViewController, animated: true)
        }
        
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
            // No洗い替え
            var counter = self.cardDataArray.count
            for card in self.cardDataArray {
                card.no = counter
                counter = counter - 1
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
