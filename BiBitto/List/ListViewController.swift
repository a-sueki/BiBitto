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

class ListViewController: TabmanViewController, PageboyViewControllerDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var viewControllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: ListViewController viewDidLoad start")

        self.dataSource = self
        
        // configure the bar
        self.bar.items = [Item(title: "Page 1"),
                          Item(title: "Page 2")]
        
        // show search button and set action
        let rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchButtonTapped))
        // add the button to navigationBar
        self.navigationItem.setRightBarButtonItems([rightSearchBarButtonItem], animated: true)

        print("DEBUG_PRINT: ListViewController viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func searchButtonTapped() {
        print("DEBUG_PRINT: ListViewController searchButtonTapped start")
        print("DEBUG_PRINT: ListViewController searchButtonTapped end")
        
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
    

}

