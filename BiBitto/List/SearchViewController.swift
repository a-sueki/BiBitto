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
        
        print(Bundle.main.path(forResource: "data", ofType: "txt"))

        dataSource = SimplePrefixQueryDataSource(data)
        

        ramReel = RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>(frame: self.view.frame, dataSource: dataSource, placeholder: "Start by typing…") {
            print("Plain:", $0)
        }
        
        ramReel.hooks.append {
            let r = Array($0.characters.reversed())
            let j = String(r)
            print("Reversed:", j)
        }
        
        self.view.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        print("DEBUG_PRINT: SearchViewController viewWillAppear end")
    }
    
    fileprivate let data: [String] = {
        print("DEBUG_PRINT: SearchViewController fileprivate start")
       do {
            guard let dataPath = Bundle.main.path(forResource: "data", ofType: "txt") else {
                return []
            }
            print("dataPath = " + dataPath)

            let data = try WordReader(filepath: dataPath)
        
            print(data.words)
            return data.words

        }
        catch let error {
            print(error)
            return []
        }
    }()
}
