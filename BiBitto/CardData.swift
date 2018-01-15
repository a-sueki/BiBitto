//
//  CardData.swift
//  BiBitto
//
//  Created by admin on 2017/10/24.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class CardData: NSObject {

    var id: String?
    var no: String
    var text: String
    var title: String?
    var author: String?
    var category: String
    var createAt: NSDate
    var updateAt: NSDate
    
    init(valueDictionary: [String: AnyObject]) {
        self.no = valueDictionary["no"] as! String
        self.text = valueDictionary["text"] as! String
        self.title = valueDictionary["title"] as? String
        self.author = valueDictionary["author"] as? String
        self.category = valueDictionary["category"] as! String
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        let updateAt = valueDictionary["updateAt"] as? String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
    }
    
    convenience init(snapshot: DataSnapshot) {

        let valueDictionary = snapshot.value as! [String: AnyObject]
        self.init(valueDictionary: valueDictionary)
        self.id = snapshot.key
        
    }
    
}
