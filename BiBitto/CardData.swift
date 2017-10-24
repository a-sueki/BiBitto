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

    var id: String
    var no: Int
    var text: String
    var title: String?
    var author: String?
    var category: String?

    init(snapshot: DataSnapshot, id: String) {

        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.no = valueDictionary["no"] as! Int
        self.text = valueDictionary["text"] as! String
        self.title = valueDictionary["title"] as? String
        self.author = valueDictionary["author"] as? String
        self.category = valueDictionary["category"] as? String

    }
}
