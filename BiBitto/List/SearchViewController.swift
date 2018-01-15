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
            //TODO: 選択された単語で$0フィルタリング
            
            //TODO: 一覧に戻る
            
        }
        
        ramReel.hooks.append {
            let r = Array($0.characters.reversed())
            let j = String(r)
            print("Reversed:", j) //Reversed: yldrawkwa
        }
        
        self.view.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        print("DEBUG_PRINT: SearchViewController viewWillAppear end")
    }
}

