//
//  SearchViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import RAMReel

class SearchViewController: UIViewController , UICollectionViewDelegate{
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    var cardDataArray: [CardData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: SearchViewController viewWillAppear start")
        
        let words = Files.readDocument(fileName: Files.word_file)
        dataSource = SimplePrefixQueryDataSource(words)
        
        let ramReel = RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>(frame: self.view.frame, dataSource: dataSource, placeholder: "Start by typing…") {
            print("Plain:", $0)
        }
        
        var refinedCardDataArray = Array<CardData>()
        ramReel.hooks.append {
            
            for card in self.cardDataArray {
                //大文字小文字を無視させて評価
                if card.text.lowercased().contains($0) || card.text.localizedCaseInsensitiveContains($0){
                    refinedCardDataArray.append(card)
                }
            }
            // 一覧へのデータ渡し
            let nav = self.navigationController!
            //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
            let listViewController = nav.viewControllers[nav.viewControllers.count-2] as! ListViewController
            listViewController.cardDataArray = refinedCardDataArray
            // 前画面に戻る
            self.navigationController?.popViewController(animated: false)

        }
        
        self.view.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        print("DEBUG_PRINT: SearchViewController viewWillAppear end")
    }
}

